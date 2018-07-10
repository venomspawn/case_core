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
              op_id:      '1abc',
              state:      'ok',
              rguid:      '101'
            },
            {
              op_id:      '2abc',
              state:      'error',
              rguid:      '1001'
            },
            {
              op_id:      '2bbc',
              state:      'closed',
              rguid:      '10001'
            },
            {
              op_id:      '2bbb',
              state:      'issue',
              rguid:      '100001'
            },
            {
              op_id:      '3abc',
              state:      'ok',
              rguid:      '1000001'
            }
          ].freeze

          # Названия импортируемых полей атрибутов
          FIELDS = %i[request_id name value].freeze

          # Создаёт записи межведомственных запросов вместе с записями
          # атрибутов, после чего возвращает созданные записи межведомственных
          # запросов
          # @param [CaseCore::Models::Case] c4s3
          #   запись заявки, в рамках которой создаются записи межведомственных
          #   запросов
          # @return [Array<CaseCore::Models::Request>]
          #   список созданных записей межведомственных запросов
          def create_requests(c4s3)
            args = [DATA.size, case_id: c4s3.id]
            FactoryBot.create_list(:request, *args).tap do |requests|
              values = DATA.size.times.each_with_object([]) do |i, memo|
                id = requests[i].id
                DATA[i].each { |name, value| memo << [id, name.to_s, value] }
              end
              Models::RequestAttribute.import(FIELDS, values)
            end
          end
        end
      end
    end
  end
end
