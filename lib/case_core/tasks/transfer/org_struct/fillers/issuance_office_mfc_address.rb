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
          # адресу офиса МФЦ, в котором заявке выставлен статус `issuance`
          class IssuanceOfficeMFCAddress < Base::Filler
            def initialize(db, c4s3, memo)
              operator_id = c4s3['issuance_operator_id']
              employee = db.employees[operator_id] || {}
              office_id = employee[:office_id]
              address = db.addresses[office_id] || {}
              super(address, memo)
            end

            private

            # Ассоциативный массив, в котором названиям полей записи
            # `org_structure` соответствуют названия атрибутов заявки
            NAMES = {
              zip:        'issuance_office_mfc_index',
              region:     'issuance_office_mfc_region_name',
              sub_region: 'issuance_office_mfc_district',
              city:       'issuance_office_mfc_city',
              settlement: 'issuance_office_mfc_settlement',
              street:     'issuance_office_mfc_street',
              house:      'issuance_office_mfc_house',
              building:   'issuance_office_mfc_building',
              appartment: 'issuance_office_mfc_room'
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
