# frozen_string_literal: true

module CaseCore
  need 'helpers/log'
  need 'tasks/transfer/extractors/documents'
  need 'tasks/transfer/importers/file'

  module Tasks
    class Transfer
      module Importers
        # Класс объектов, импортирующих записи документов заявок и содержимое
        # их файлов
        class Documents
          include CaseCore::Helpers::Log

          # Импортирует записи документов заявок и содержимое их файлов
          # @param [CaseCore::Tasks::Transfer::DataHub] hub
          #   объект, предоставляющий доступ к данным
          def self.import(hub)
            new(hub).import
          end

          # Инициализирует объект класса
          # @param [CaseCore::Tasks::Transfer::DataHub] hub
          #   объект, предоставляющий доступ к данным
          def initialize(hub)
            @hub = hub
          end

          # Список полей записей документов
          DOCUMENT_COLUMNS = Models::Document.columns

          # Импортирует записи документов заявок и содержимое их файлов
          def import
            documents.each(&File.method(:import))
            Models::Document.import(DOCUMENT_COLUMNS, document_values)
            log_imported_documents(binding)
          end

          private

          # Объект, предоставляющий доступ к данным
          # @return [CaseCore::Tasks::Transfer::DataHub]
          #   объект, предоставляющий доступ к данным
          attr_reader :hub

          # Возвращает список ассоциативных массивов с информацией о документах
          # @return [Array]
          #   результирующий список
          def documents
            @documents ||= Extractors::Documents.extract(hub)
          end

          # Возвращает список списков значений полей записей документов
          # @return [Array<Array>]
          #   результирующий список
          def document_values
            @document_values ||=
              documents
              .select { |h| h[:fs_id].present? }
              .map { |h| h.values_at(*DOCUMENT_COLUMNS) }
          end

          # Создаёт запись в журнале событий о том, что импортированы записи
          # документов
          # @param [Binding] context
          #   контекст
          def log_imported_documents(context)
            log_info(context) { <<-MESSAGE }
              Импортированы записи документов в количестве
              #{document_values.size} из #{documents.size}
            MESSAGE
          end
        end
      end
    end
  end
end
