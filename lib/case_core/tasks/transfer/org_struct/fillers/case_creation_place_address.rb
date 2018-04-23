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
          # адресу места регистрации заявки
          class CaseCreationPlaceAddress < Base::Filler
            def initialize(db, c4s3, memo)
              operator_id = c4s3['operator_id']
              employee = db.employees[operator_id] || {}
              office_id = employee[:office_id]
              address = db.addresses[office_id] || {}
              super(address, memo)
            end

            private

            # Ассоциативный массив, в котором названиям полей записи
            # `org_structure` соответствуют названия атрибутов заявки
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
