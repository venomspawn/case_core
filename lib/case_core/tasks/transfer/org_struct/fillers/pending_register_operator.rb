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
          # оператору, поместившему документы заявки в реестр передаваемой
          # корреспонденции
          class PendingRegisterOperator < Base::Filler
            def initialize(db, c4s3, memo)
              operator_id = c4s3['pending_register_operator_id']
              employee = db.employees[operator_id] || {}
              super(employee, memo)
            end

            private

            # Ассоциативный массив, в котором названиям полей записи
            # `org_structure` соответствуют названия атрибутов заявки
            NAMES = {
              first_name:  'pending_register_operator_name',
              middle_name: 'pending_register_operator_middle_name',
              last_name:   'pending_register_operator_surname',
              position:    'pending_register_operator_position'
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
