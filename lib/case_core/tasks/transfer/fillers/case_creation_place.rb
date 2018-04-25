# frozen_string_literal: true

require_relative 'base/filler'

module CaseCore
  module Tasks
    class Transfer
      module Fillers
        # Класс объектов, извлекающих атрибуты заявки, которые относятся к
        # месту регистрации заявки
        class CaseCreationPlace < Base::Filler
          # Ассоциативный массив, в котором названиям полей записи места
          # регистрации заявки соответствуют названия атрибутов заявки
          NAMES = {
            name:  'case_creation_place_name',
            kpp:   'case_creation_place_kpp',
            esia:  'case_creation_place_esia',
            oktmo: 'case_creation_place_oktmo'
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
            hub.operator_office(operator_id)
          end
        end
      end
    end
  end
end
