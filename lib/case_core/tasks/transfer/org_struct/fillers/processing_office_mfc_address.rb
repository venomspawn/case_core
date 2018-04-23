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
          # адресу места отправления реестра передаваемой корреспонденции с
          # документами заявки на обработку
          class ProcessingPlaceAddress < Base::Filler
            def initialize(db, c4s3, memo)
              office_id = c4s3['processing_place_id']
              address = db.addresses[office_id] || {}
              super(address, memo)
            end

            private

            # Ассоциативный массив, в котором названиям полей записи
            # `org_structure` соответствуют названия атрибутов заявки
            NAMES = {
              zip:        'processing_office_mfc_index',
              region:     'processing_office_mfc_region_name',
              sub_region: 'processing_office_mfc_district',
              city:       'processing_office_mfc_city',
              settlement: 'processing_office_mfc_settlement',
              street:     'processing_office_mfc_street',
              house:      'processing_office_mfc_house',
              building:   'processing_office_mfc_building',
              appartment: 'processing_office_mfc_room'
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
