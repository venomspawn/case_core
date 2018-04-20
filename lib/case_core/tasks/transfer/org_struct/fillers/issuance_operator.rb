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
          # оператору, выставившему статус заявки `issuance`
          class IssuanceOperator < Base::Filler
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
              operator_id = c4s3['issuance_operator_id']
              ecm_person = mfc_db.ecm_people[operator_id] || {}
              org_struct_id = ecm_person[:org_struct_id]&.to_i
              employee = os_db.employees[org_struct_id] || {}
              super(employee, memo)
            end

            private

            # Ассоциативный массив, в котором названиям полей записи
            # `org_structure` соответствуют названия атрибутов заявки
            NAMES = {
              first_name:  'issuance_operator_name',
              middle_name: 'issuance_operator_middle_name',
              last_name:   'issuance_operator_surname',
              position:    'issuance_operator_position'
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
