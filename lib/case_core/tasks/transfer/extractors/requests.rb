# frozen_string_literal: true

require 'set'

module CaseCore
  module Tasks
    class Transfer
      module Extractors
        # Класс объектов, предоставляющих возможность извлечения информации о
        # межведомственных запросах
        class Requests
          # Возвращает список ассоциативных массивов с информацией о
          # межведомственных запросах
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

          # Возвращает список ассоциативных массивов с информацией о
          # межведомственных запросах
          # @return [Array]
          #   результирующий список
          def extract
            hub.cm.requests.select do |request|
              supported_ids.include?(request[:case_id])
            end
          end

          private

          # Объект, предоставляющий доступ к записям заявок в базе данных
          # `case_manager`
          # @return [CaseCore::Tasks::Transfer::DataHub]
          #   объект, предоставляющий доступ к данным
          attr_reader :hub

          # Поддерживаемые типы заявок
          SUPPORTED_TYPES = %w[msp_case].freeze

          # Возвращает множество идентификаторов записей заявок,
          # присутствующих в базе `case_core`
          # @return [Set<String>]
          #   результирующее множество
          def supported_ids
            @supported_ids ||=
              Models::Case.where(type: SUPPORTED_TYPES).select_map(:id).to_set
          end
        end
      end
    end
  end
end
