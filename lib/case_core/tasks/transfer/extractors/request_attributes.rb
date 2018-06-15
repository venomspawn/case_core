# frozen_string_literal: true

module CaseCore
  module Tasks
    class Transfer
      module Extractors
        # Класс объектов, предоставляющих возможность извлечения информации
        # об атрибутах межведомственного запроса для импорта
        class RequestAttributes
          # Возвращает ассоциативный массив атрибутов межведомственного запроса
          # @param [Hash] request
          #   ассоциативный массив атрибутов записи межведомственного запроса в
          #   `case_manager`
          # @param [Hash] types
          #   ассоциативный массив, в котором идентификаторам заявок
          #   сопоставлены типы заявок
          # @return [Hash]
          #   результирующий ассоциативный массив
          def self.extract(request, types)
            new(request, types).extract
          end

          # Инициализирует объект класса
          # @param [Hash] request
          #   ассоциативный массив атрибутов записи межведомственного запроса в
          #   `case_manager`
          # @param [Hash] types
          #   ассоциативный массив, в котором идентификаторам заявок
          #   сопоставлены типы заявок
          def initialize(request, types)
            @request = request
            @types = types
          end

          # Ассоциативный массив, в котором типу заявки сопоставляется название
          # атрибута, содержащего в себе идентификатор сообщения СМЭВ
          MESSAGE_ID_NAME = {
            'cik_case' => 'cik_message_id',
            'msp_case' => 'msp_message_id',
            'mvd_case' => 'mvd_message_id'
          }.freeze

          # Возвращает ассоциативный массив атрибутов межведомственного запроса
          # @return [Hash] request
          #   результирующий ассоциативный массив
          def extract
            {}.tap do |result|
              result['response_content'] = request[:response_content]
              result['response_signature'] = request[:response_signature]
              case_id = request[:case_id]
              type = types[case_id]
              name = MESSAGE_ID_NAME[type]
              result[name] = request[:id]
              result.delete_if { |k, v| k.blank? || v.blank? }
            end
          end

          private

          # Ассоциативный массив с информацией о межведомственном запросе
          # @return [Hash]
          #   ассоциативный массив с информацией о межведомственном запросе
          attr_reader :request

          # Ассоциативный массив, в котором идентификаторам заявок сопоставлены
          # типы заявок
          # @return [Hash]
          #   ассоциативный массив с информацией о типах заявок
          attr_reader :types
        end
      end
    end
  end
end
