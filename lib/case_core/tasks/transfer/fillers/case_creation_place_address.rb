# frozen_string_literal: true

require_relative 'base/filler'

module CaseCore
  module Tasks
    class Transfer
      module Fillers
        # Класс объектов, извлекающих атрибуты заявки, которые относятся к
        # адресу места регистрации заявки
        class CaseCreationPlaceAddress < Base::Filler
          # Ассоциативный массив, в котором названиям полей записи
          # соответствуют названия атрибутов заявки
          NAMES = {
            zip:        'case_creation_place_index',
            region:     'case_creation_place_region_name',
            sub_region: 'case_creation_place_district',
            city:       'case_creation_place_city',
            settlement: 'case_creation_place_settlement',
            street:     'case_creation_place_street',
            house:      'case_creation_place_house',
            building:   'case_creation_place_building',
            appartment: 'case_creation_place_room'
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
            hub.operator_office_address(operator_id)
          end
        end
      end
    end
  end
end
