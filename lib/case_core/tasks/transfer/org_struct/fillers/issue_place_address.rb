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
          # адресу места выдачи заявки
          class IssuePlaceAddress < Base::Filler
            def initialize(db, c4s3, memo)
              issue_method = c4s3['issue_method']
              office_id = c4s3['issue_place_id'] if issue_method == 'mfc'
              address = db.addresses[office_id] || {}
              super(address, memo)
            end

            private

            # Ассоциативный массив, в котором названиям полей записи
            # `org_structure` соответствуют названия атрибутов заявки
            NAMES = {
              zip:        'issue_place_index',
              region:     'issue_place_region_name',
              sub_region: 'issue_place_district',
              city:       'issue_place_city',
              settlement: 'issue_place_settlement',
              street:     'issue_place_street',
              house:      'issue_place_house',
              building:   'issue_place_building',
              appartment: 'issue_place_room'
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
