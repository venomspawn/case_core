# frozen_string_literal: true

require_relative 'transfer/data_hub'
require_relative 'transfer/document_files'
require_relative 'transfer/extractors/case_attributes'
require_relative 'transfer/extractors/cases'
require_relative 'transfer/extractors/documents'
require_relative 'transfer/extractors/request_attributes'
require_relative 'transfer/extractors/requests'
require_relative 'transfer/helpers'

Dir["#{__dir__}/transfer/fillers/*.rb"].each(&method(:require))

module CaseCore
  module Tasks
    # Класс объектов, осуществляющих миграцию данных из `case_manager`
    class Transfer
      include DocumentFiles
      include Helpers

      # Возвращает ассоциативный массив со статистикой по импортированным
      # атрибутам
      # @return [Hash]
      #   ассоциативный массив со статистикой по импортированным атрибутам
      def self.stats
        @stats ||= {}
      end

      # Создаёт экземпляр класса и запускает миграцию данных
      def self.launch!
        new.launch!
      end

      # Запускает миграцию данных
      def launch!
        @hub = DataHub.new
        Sequel::Model.db.transaction do
          import_cases
          import_documents
          import_requests
        end
        import_registers
      end

      private

      # Объект, предоставляющий доступ к данным
      # @return [CaseCore::Tasks::Transfer::DataHub]
      #   объект, предоставляющий доступ к данным
      attr_reader :hub

      # Импортирует записи заявок из `case_manager`
      def import_cases
        extracted_cases = Extractors::Cases.extract(hub)
        columns = Models::Case.columns
        values = extracted_cases.keys.map { |h| h.values_at(*columns) }
        Models::Case.import(columns, values)
        log_imported_cases(values.size, binding)
        import_case_attributes(extracted_cases.values)
      end

      # Импортирует атрибуты заявок из `case_manager`
      # @param [Array<Hash>] imported_cases
      #   список ассоциативных массивов с информацией об атрибутах
      #   импортированных заявок
      def import_case_attributes(imported_cases)
        values = case_attribute_values(imported_cases)
        Models::CaseAttribute.import(%i[case_id name value], values)
        log_imported_case_attributes(values.size, binding)
      end

      # Классы объектов, заполняющих атрибуты заявки
      FILLER_CLASSES = Fillers
                       .constants
                       .map(&Fillers.method(:const_get))
                       .select { |c| c.is_a?(Class) }

      # Возвращает список списков значений полей записей атрибутов заявок
      # @param [Array<Hash>] imported_cases
      #   список ассоциативных массивов с информацией об атрибутах
      #   импортированных заявок
      # @return [Array]
      #   результирующий список
      def case_attribute_values(imported_cases)
        imported_cases.each_with_object([]) do |c4s3, memo|
          attributes = Extractors::CaseAttributes.extract(c4s3)
          FILLER_CLASSES.each { |filler| filler.new(hub, attributes).fill }
          case_id = c4s3[:id]
          attributes.each { |name, value| memo << [case_id, name, value] }
        end
      end

      # Импортирует записи заявок из `case_manager`
      def import_documents
        extracted_documents = Extractors::Documents.extract(hub)
        import_files(extracted_documents)
        columns = Models::Document.columns
        values = extracted_documents.map { |h| h.values_at(*columns) }
        Models::Document.import(columns, values)
        log_imported_documents(values.size, binding)
      end

      # Импортирует файлы документов из файлового хранилища
      # @param [Array<Hash>] extracted_documents
      #   список ассоциативных массивов с информацией о документах
      def import_files(extracted_documents)
        Models::File.unrestrict_primary_key
        extracted_documents.each(&method(:import_file))
        Models::File.restrict_primary_key
      end

      # Импортирует файл документа из файлового хранилища
      # @param [Hash] doc
      #   ассоциативный массив с информацией о документе
      def import_file(doc)
        fs_id = doc.delete(:fs_id) || return
        content = file(fs_id)
        log_file_content(fs_id, content)
        return if content.nil?
        id = extract_fs_id(fs_id)
        created_at = doc[:created_at]
        Models::File.create(id: id, content: content, created_at: created_at)
        doc[:fs_id] = id
      end

      # Импортирует записи межведомственных запросов из `case_manager`
      def import_requests
        requests = Extractors::Requests.extract(hub)
        requests = requests.each_with_object({}) do |request, memo|
          params = request.slice(:case_id, :created_at)
          record = Models::Request.create(params)
          memo[record.id] = request
        end
        log_imported_requests(requests.size, binding)
        import_request_attributes(requests)
      end

      # Импортирует атрибуты междведомственных запросов
      # @param [Hash] imported_requests
      #   ассоциативный массив, в котором идентификаторам импортированных
      #   записей межведомственных запросов сопоставляются ассоциативные
      #   массивы с информацией об этих запросах
      def import_request_attributes(imported_requests)
        values = request_attribute_values(imported_requests)
        Models::RequestAttribute.import(%i[request_id name value], values)
        log_imported_request_attributes(values.size, binding)
      end

      # Возвращает список списков значений полей записей атрибутов
      # межведомственных запросов
      # @param [Hash] imported_requests
      #   ассоциативный массив, в котором идентификаторам импортированных
      #   записей межведомственных запросов сопоставляются ассоциативные
      #   массивы с информацией об этих запросах
      # @return [Array]
      #   результирующий список
      def request_attribute_values(imported_requests)
        types = Models::Case.select(:id, :type).as_hash(:id, :type)
        imported_requests.each_with_object([]) do |(request_id, request), memo|
          attributes = Extractors::RequestAttributes.extract(request, types)
          attributes.each { |name, value| memo << [request_id, name, value] }
        end
      end

      # Импортирует реестры передаваемой корреспонденции из `case_manager` в
      # `mfc`
      def import_registers
        data = extract_registers
        hub.mfc.import_registers(data)
        log_imported_registers(data.size, binding)
      end

      # Возвращает список ассоциативных массивов с импортируемой информацией о
      # реестрах передаваемой корреспонденции
      # @return [Array<Hash>]
      #   результирующий список
      def extract_registers
        hub.cm.registers.each_with_object([]) do |(id, register), memo|
          cases = hub.cm.register_cases[id]
          memo << extract_register(register, cases) unless cases.blank?
        end
      end

      # Возвращает ассоциативный массив с импортируемой информацией о реестре
      # передаваемой корреспонденции
      # @param [Hash] register
      #   ассоциативный массив атрибутов записи реестра в `case_manager`
      # @param [Array<String>]
      #   список идентиификаторов записей заявок, находящихся в реестре
      # @return [Hash]
      #   результирующий ассоциативный массив
      def extract_register(register, cases)
        register.slice(:institution_rguid, :back_office_id).tap do |result|
          office_id = register[:office_id]
          office = hub.mfc.ld_offices[office_id] || {}
          result[:institution_office_rguid] = office[:rguid]

          result[:type]    = register[:register_type]
          result[:sent]    = register[:exported]
          result[:sent_at] = register[:exported_at]
          result[:cases]   = Oj.dump(cases)
        end
      end
    end
  end
end
