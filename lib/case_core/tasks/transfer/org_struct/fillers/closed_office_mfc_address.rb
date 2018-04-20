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
          # адресу офиса МФЦ, в котором заявке выставлен статус `closed`
          class ClosedOfficeMFCAddress < Base::Filler
            def initialize(db, c4s3, memo)
              operator_id = c4s3['closed_operator_id']
              employee = db.employees[operator_id] || {}
              office_id = employee[:office_id]
              address = db.addresses[office_id] || {}
              super(address, memo)
            end

            private

            # Ассоциативный массив, в котором названиям полей записи
            # `org_structure` соответствуют названия атрибутов заявки
            NAMES = {
              zip:        'closed_office_mfc_index',
              region:     'closed_office_mfc_region_name',
              sub_region: 'closed_office_mfc_district',
              city:       'closed_office_mfc_city',
              settlement: 'closed_office_mfc_settlement',
              street:     'closed_office_mfc_street',
              house:      'closed_office_mfc_house',
              building:   'closed_office_mfc_building',
              appartment: 'closed_office_mfc_room'
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
