# frozen_string_literal: true

module CaseCore
  need 'actions/cases/count/result_schema'

  module Actions
    module Cases
      class Count
        # Вспомогательный модуль, предназначенный для включения в тесты
        # содержащего класса
        module SpecHelper
          # Возвращает JSON-схему результата действия
          # @return [Object]
          #   JSON-схема результата действия
          def schema
            RESULT_SCHEMA
          end

          # Ассоциативный массив, в котором моделям соответствуют списки
          # импортируемых значений
          DATA = [
            {
              id:         '1',
              type:       'test_case',
              created_at: Time.now,
              op_id:      '1abc',
              state:      'ok',
              rguid:      '101'
            },
            {
              id:         '2',
              type:       'test_case',
              created_at: Time.now,
              op_id:      '2abc',
              state:      'error',
              rguid:      '1001'
            },
            {
              id:         '3',
              type:       'spec_case',
              created_at: Time.now,
              op_id:      '2bbc',
              state:      'closed',
              rguid:      '10001'
            },
            {
              id:         '4',
              type:       'spec_case',
              created_at: Time.now,
              op_id:      '2bbb',
              state:      'issue',
              rguid:      '100001'
            },
            {
              id:         '5',
              type:       'spec_case',
              created_at: Time.now,
              op_id:      '3abc',
              state:      'ok',
              rguid:      '1000001'
            }
          ].freeze

          # Создаёт записи заявок вместе с записями атрибутов, после чего
          # возвращает созданные записи заявок
          # @return [Array<CaseCore::Models::Case>]
          #   список созданных записей заявок
          def create_cases
            FactoryBot.create(:imported_cases, data: DATA)
          end
        end
      end
    end
  end
end
