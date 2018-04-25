# frozen_string_literal: true

require_relative 'base/filler'

module CaseCore
  module Tasks
    class Transfer
      module Fillers
        # Класс объектов, извлекающих атрибуты заявки, которые относятся к
        # оператору, отправившему реестр передаваемой корреспонденции с
        # документами заявки на обработку в ведомство
        class ProcessingOperator < Base::Filler
          # Ассоциативный массив, в котором названиям полей записи
          # соответствуют названия атрибутов заявки
          NAMES = {
            first_name:  'processing_operator_name',
            middle_name: 'processing_operator_middle_name',
            last_name:   'processing_operator_surname',
            position:    'processing_operator_position'
          }.freeze

          private

          # Возвращает ассоциативный массив полей записи
          # @param [CaseCore::Tasks::Transfer::DataHub] hub
          #   объект, предоставляющий доступ к данным
          # @param [Hash] c4s3
          #   ассоциативный массив с информацией о заявке
          # @return [Hash]
          #   ассоциативный массив полей записи
          def extract_record(hub, c4s3)
            operator_id = c4s3['processing_operator_id']
            hub.operator_employee(operator_id)
          end
        end
      end
    end
  end
end
