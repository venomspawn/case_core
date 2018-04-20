# frozen_string_literal: true

require_relative 'base/filler'

module CaseCore
  module Tasks
    class Transfer
      module OrgStruct
        # Пространство имён классов объектов, извлекающих атрибуты заявки из
        # `org_structure`
        module Fillers
          # Класс объектов, извлекающих атрибуты заявки, которые относятся к
          # адресу места формирования пакета документов
          class PackagingPlaceAddress < Base::Filler
            def initialize(db, c4s3, memo)
              office_id = c4s3['packaging_place_id']
              address = db.addresses[office_id] || {}
              super(address, memo)
            end

            private

            # Ассоциативный массив, в котором названиям полей записи
            # `org_structure` соответствуют названия атрибутов заявки
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

            # Возвращает ассоциативный массив, в котором названиям полей записи
            # `org_structure` соответствуют названия атрибутов заявки
            # @return [Hash]
            #   результирующий ассоциативный массив
            def names
              NAMES
            end
          end
        end
      end
    end
  end
end
