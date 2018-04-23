# frozen_string_literal: true

require_relative 'base/filler'

module CaseCore
  module Tasks
    class Transfer
      module Fillers
        # Класс объектов, извлекающих атрибуты заявки, которые относятся к
        # адресу места формирования пакета документов
        class PackagingPlaceAddress < Base::Filler
          # Ассоциативный массив, в котором названиям полей записи
          # соответствуют названия атрибутов заявки
          NAMES = {
            zip:        'packaging_place_index',
            region:     'packaging_place_region_name',
            sub_region: 'packaging_place_district',
            city:       'packaging_place_city',
            settlement: 'packaging_place_settlement',
            street:     'packaging_place_street',
            house:      'packaging_place_house',
            building:   'packaging_place_building',
            appartment: 'packaging_place_room'
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
            office_id = c4s3['packaging_place_id']
            hub.os.addresses[office_id] || {}
          end
        end
      end
    end
  end
end
