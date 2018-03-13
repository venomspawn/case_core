# frozen_string_literal: true

module CaseCore
  module Actions
    module Cases
      class Index
        # Вспомогательный модуль, предназначенный для включения в тесты
        # содержащего класса
        module SpecHelper
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
            FactoryGirl.create(:imported_cases, data: DATA)
          end
        end
      end
    end
  end
end
