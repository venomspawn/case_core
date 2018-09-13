# frozen_string_literal: true

module CaseCore
  need 'actions/documents/create'
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

          # Список названий полей, извлекаемых из ассоциативного массива с
          # информацией о документах
          FIELDS =
            Actions::Documents::Create::PARAMS_SCHEMA[:properties].keys.freeze

          # Импортирует записи документов заявок и содержимое их файлов
          def import
            documents.each do |document|
              document.slice!(*FIELDS)
              File.import(document)
              document[:created_at] = document[:created_at]&.strftime('%FT%T')
              Actions::Documents::Create.new(document).create
            end
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

          # Создаёт запись в журнале событий о том, что импортированы записи
          # документов
          # @param [Binding] context
          #   контекст
          def log_imported_documents(context)
            log_info(context) { <<-MESSAGE }
              Импортированы записи документов в количестве #{documents.size}
            MESSAGE
          end
        end
      end
    end
  end
end
