# frozen_string_literal: true

module CaseCore
  module Actions
    module Requests
      class Count
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

          # Создаёт записи межведомственных запросов вместе с записями
          # атрибутов, после чего возвращает созданные записи межведомственных
          # запросов
          # @param [CaseCore::Models::Case] c4s3
          #   запись заявки, в рамках которой создаются записи межведомственных
          #   запросов
          # @return [Array<CaseCore::Models::Request>]
          #   список созданных записей заявок
          def create_requests(c4s3)
            DATA.map do |attrs|
              FactoryGirl.create(:request, case_id: c4s3.id).tap do |request|
                attrs.each do |name, value|
                  args = { request_id: request.id, name: name, value: value }
                  FactoryGirl.create(:request_attribute, args)
                end
              end
            end
          end
        end
      end
    end
  end
end
