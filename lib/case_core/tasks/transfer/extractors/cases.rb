# frozen_string_literal: true

require 'set'

require_relative 'case'

module CaseCore
  module Tasks
    class Transfer
      # Пространство имён классов объектов, предоставляющих возможность
      # извлечения информации о заявках и атрибутах заявок
      module Extractors
        # Класс объектов, предоставляющих возможность извлечения информации о
        # заявках для импорта
        class Cases
          # Возвращает ассоциативный массив, в котором ключами являются
          # ассоциативные массивы с атрибутами записей заявок в `case_core`,
          # а значениями — ассоциативные массивы с атрибутами записей заявок
          # в `case_manager`
          # @param [CaseCore::Tasks::Transfer::DataHub] hub
          #   объект, предоставляющий доступ к данным
          # @return [Hash]
          #   результирующий ассоциативный массив
          def self.extract(hub)
            new(hub).extract
          end

          # Инициализирует объект класса
          # @param [CaseCore::Tasks::Transfer::DataHub] hub
          #   объект, предоставляющий доступ к данным
          def initialize(hub)
            @hub = hub
          end

          # Возвращает ассоциативный массив, в котором ключами являются
          # ассоциативные массивы с атрибутами записей заявок в `case_core`,
          # а значениями — ассоциативные массивы с атрибутами записей заявок
          # в `case_manager`
          # @return [Hash]
          #   результирующий ассоциативный массив
          def extract
            hub.cm.cases.each_with_object({}) do |cm_case, memo|
              cc_case = extract_case(cm_case)
              memo[cc_case] = cm_case unless cc_case.nil?
            end
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

          # Возвращает ассоциативный массив атрибутов записи заявки, если
          # запись заявки возможно импортировать, или `nil` в противном
          # случае
          # @param [Hash] c4s3
          #   ассоциативный массив с информацией о заявке
          # @return [Hash]
          #   ассоциативный массив атрибутов записи заявки
          # @return [NilClass]
          #   если запись заявки невозможно импортировать
          def extract_case(c4s3)
            Case.extract(c4s3, already_imported_ids)
          end
        end
      end
    end
  end
end
