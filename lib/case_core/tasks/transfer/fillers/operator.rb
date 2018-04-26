# frozen_string_literal: true

require_relative 'base/filler'

module CaseCore
  module Tasks
    class Transfer
      module Fillers
        # Класс объектов, извлекающих атрибуты заявки, которые относятся к
        # оператору, зарегистрировавшего заявку
        class Operator < Base::Filler
          # Ассоциативный массив, в котором названиям полей записи
          # соответствуют названия атрибутов заявки
          NAMES = {
            first_name:      'operator_name',
            middle_name:     'operator_middle_name',
            last_name:       'operator_surname',
            position:        'operator_position',
            passport_number: 'operator_passport_number',
            passport_series: 'operator_passport_series',
            snils:           'operator_snils'
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
            operator_id = c4s3['operator_id']
            hub.operator_employee(operator_id)
          end
        end
      end
    end
  end
end
