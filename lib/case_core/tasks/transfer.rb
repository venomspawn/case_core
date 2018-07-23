# frozen_string_literal: true

require_relative 'transfer/data_hub'
require_relative 'transfer/document_files'
require_relative 'transfer/extractors/documents'
require_relative 'transfer/helpers'
require_relative 'transfer/importers/cases'
require_relative 'transfer/importers/registers'
require_relative 'transfer/importers/requests'

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
          Importers::Cases.import(hub)
          Importers::Requests.import(hub)
          #import_documents
        end
        Importers::Registers.import(hub)
      end

      private

      # Объект, предоставляющий доступ к данным
      # @return [CaseCore::Tasks::Transfer::DataHub]
      #   объект, предоставляющий доступ к данным
      attr_reader :hub

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
    end
  end
end
