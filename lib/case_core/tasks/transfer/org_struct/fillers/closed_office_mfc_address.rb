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
            # Инициализирует объект класса
            # @param [CaseCore::Tasks::Transfer::OrgStruct::DB] os_db
            #   объект, предоставляющий доступ к `org_struct`
            # @param [CaseCore::Tasks::Transfer::MFC::DB] mfc_db
            #   объект, предоставляющий доступ к `mfc`
            # @param [Hash] c4s3
            #   ассоциативный массив с информацией о заявке
            # @param [Hash] memo
            #   ассоциативный массив с атрибутами заявки
            def initialize(os_db, mfc_db, c4s3, memo)
              operator_id = c4s3['closed_operator_id']
              ecm_person = mfc_db.ecm_people[operator_id] || {}
              org_struct_id = ecm_person[:org_struct_id]&.to_i
              employee = os_db.employees[org_struct_id] || {}
              office_id = employee[:office_id]
              address = os_db.addresses[office_id] || {}
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
