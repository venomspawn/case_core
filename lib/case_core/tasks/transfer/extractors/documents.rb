# frozen_string_literal: true

require 'set'

module CaseCore
  module Tasks
    class Transfer
      module Extractors
        # Класс объектов, предоставляющих возможность извлечения информации о
        # документах для импорта
        class Documents
          # Возвращает список ассоциативных массивов с информацией о документах
          # @param [CaseCore::Tasks::Transfer::DataHub] hub
          #   объект, предоставляющий доступ к данным
          # @return [Array]
          #   результирующий список
          def self.extract(hub)
            new(hub).extract
          end

          # Инициализирует объект класса
          # @param [CaseCore::Tasks::Transfer::DataHub] hub
          #   объект, предоставляющий доступ к данным
          def initialize(hub)
            @hub = hub
          end

          # Возвращает список ассоциативных массивов с информацией о документах
          # @return [Array]
          #   результирующий список
          def extract
            hub.cm.documents.each_with_object([], &method(:extract_document))
          end

          private

          # Объект, предоставляющий доступ к записям заявок в базе данных
          # `case_manager`
          # @return [CaseCore::Tasks::Transfer::DataHub]
          #   объект, предоставляющий доступ к данным
          attr_reader :hub

          # Возвращает множество идентификаторов записей заявок,
          # присутствующих в базе `case_core`
          # @return [Set<String>]
          #   результирующее множество
          def already_imported_ids
            @already_imported_ids ||= Models::Case.select_map(:id).to_set
          end

          # Ассоциативный массив со значениями, сигнализирующими о том,
          # является ли документ необходимым для получения услуги или
          # результатом оказания услуги
          DIRECTION = { 1 => 'input', 2 => 'output' }.freeze

          # Ассоциативный массив со значениями, сигнализирующими о том, в каком
          # виде предоставлен документ
          PROVIDED_AS = {
            1 => 'original',
            2 => 'copy',
            3 => 'notarized_copy',
            4 => 'doc_list'
          }.freeze

          # Добавляет ассоциативный массив с информацией о документе в список
          # @param [Hash] doc
          #   ассоциативный массив атрибутов записи документа
          # @param [Array] memo
          #   список ассоциативных массивов с информацией о документах
          def extract_document(doc, memo)
            return unless already_imported_ids.include?(doc[:case_id])
            direction = doc[:direction]
            doc[:direction] = DIRECTION[direction]
            provided_as = doc[:provided_as]
            doc[:provided_as] = PROVIDED_AS[provided_as]
            memo << doc
          end
        end
      end
    end
  end
end
