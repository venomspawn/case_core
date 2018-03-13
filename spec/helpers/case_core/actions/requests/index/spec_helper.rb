# frozen_string_literal: true

module CaseCore
  module Actions
    module Requests
      class Index
        # Вспомогательный модуль, предназначенный для включения в тесты
        # содержащего класса
        module SpecHelper
          # Ассоциативный массив, в котором моделям соответствуют списки
          # импортируемых значений
          DATA = [
            {
              id:         1,
              created_at: Time.now,
              op_id:      '1abc',
              state:      'ok',
              rguid:      '101'
            },
            {
              id:         2,
              created_at: Time.now,
              op_id:      '2abc',
              state:      'error',
              rguid:      '1001'
            },
            {
              id:         3,
              created_at: Time.now,
              op_id:      '2bbc',
              state:      'closed',
              rguid:      '10001'
            },
            {
              id:         4,
              created_at: Time.now,
              op_id:      '2bbb',
              state:      'issue',
              rguid:      '100001'
            },
            {
              id:         5,
              created_at: Time.now,
              op_id:      '3abc',
              state:      'ok',
              rguid:      '1000001'
            }
          ].freeze

          # Создаёт записи межведомственных запросов вместе с записями
          # атрибутов, после чего возвращает созданные записи межведомственных
          # запросов
          # @param [CaseCore::Models::Case] c4s3
          #   запись заявки, в рамках которой создаются записи межведомственных
          #   запросов
          # @return [Array<CaseCore::Models::Request>]
          #   список созданных записей заявок
          def create_requests(c4s3)
            FactoryGirl
              .create(:imported_requests, case_id: c4s3.id, data: DATA)
          end
        end
      end
    end
  end
end
