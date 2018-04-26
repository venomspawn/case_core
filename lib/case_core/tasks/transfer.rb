# frozen_string_literal: true

require "#{$lib}/helpers/log"

require_relative 'transfer/data_hub'
require_relative 'transfer/extractors/case_attributes'
require_relative 'transfer/extractors/cases'
require_relative 'transfer/extractors/documents'
require_relative 'transfer/extractors/request_attributes'
require_relative 'transfer/extractors/requests'

Dir["#{__dir__}/transfer/fillers/*.rb"].each(&method(:require))

module CaseCore
  module Tasks
    # Класс объектов, осуществляющих миграцию данных из `case_manager`
    class Transfer
      include Helpers::Log

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
        Sequel::Model.db.transaction do
          @hub = DataHub.new
          import_cases
          import_documents
          import_requests
        end
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

      # Создаёт запись в журнале событий о том, что импортированы записи заявок
      # @param [Integer] count
      #   количество импортированных записей заявок
      # @param [Binding] context
      #   контекст
      def log_imported_cases(count, context)
        log_info(context) { <<-MESSAGE }
          Импортированы записи заявок в количестве #{count}
        MESSAGE
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

      # Создаёт запись в журнале событий о том, что импортированы атрибуты
      # заявок
      # @param [Integer] count
      #   количество импортированных атрибутов заявок
      # @param [Binding] context
      #   контекст
      def log_imported_case_attributes(count, context)
        log_info(context) { <<-MESSAGE }
          Импортированы атрибуты заявок в количестве #{count}
        MESSAGE
        Transfer.stats.keys.sort.each do |name|
          log_debug(context) { "#{name}: #{Transfer.stats[name]}" }
        end
        Transfer.stats.select { |_, v| v.zero? }.keys.sort.each do |name|
          log_debug(context) { "#{name}: zero" }
        end
      end

      # Импортирует записи заявок из `case_manager`
      def import_documents
        extracted_documents = Extractors::Documents.extract(hub)
        columns = Models::Document.columns
        values = extracted_documents.map { |h| h.values_at(*columns) }
        Models::Document.import(columns, values)
        log_imported_documents(values.size, binding)
      end

      # Создаёт запись в журнале событий о том, что импортированы записи
      # документов
      # @param [Integer] count
      #   количество импортированных записей документов
      # @param [Binding] context
      #   контекст
      def log_imported_documents(count, context)
        log_info(context) { <<-MESSAGE }
          Импортированы записи документов в количестве #{count}
        MESSAGE
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

      # Создаёт запись в журнале событий о том, что импортированы записи
      # межведомственных запросов
      # @param [Integer] count
      #   количество импортированных записей межведомственных запросов
      # @param [Binding] context
      #   контекст
      def log_imported_requests(count, context)
        log_info(context) { <<-MESSAGE }
          Импортированы записи межведомственных запросов в количестве #{count}
        MESSAGE
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

      # Создаёт запись в журнале событий о том, что импортированы атрибуты
      # межведомственных запросов
      # @param [Integer] count
      #   количество импортированных атрибутов межведомственных запросов
      # @param [Binding] context
      #   контекст
      def log_imported_request_attributes(count, context)
        log_info(context) { <<-MESSAGE }
          Импортированы атрибуты межведомственных запросов в количестве
          #{count}
        MESSAGE
      end
    end
  end
end
