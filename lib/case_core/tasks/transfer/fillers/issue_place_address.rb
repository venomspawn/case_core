# frozen_string_literal: true

require_relative 'base/filler'

module CaseCore
  module Tasks
    class Transfer
      module Fillers
        # Класс объектов, извлекающих атрибуты заявки, которые относятся к
        # адресу места выдачи заявки
        class IssuePlaceAddress < Base::Filler
          # Ассоциативный массив, в котором названиям полей записи
          # соответствуют названия атрибутов заявки
          NAMES = {
            zip:        'issue_place_index',
            country:    'issue_place_country_name',
            region:     'issue_place_region_name',
            sub_region: 'issue_place_district',
            district:   'issue_place_district',
            city:       'issue_place_city',
            settlement: 'issue_place_settlement',
            street:     'issue_place_street',
            house:      'issue_place_house',
            building:   'issue_place_building',
            appartment: 'issue_place_room'
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
            office_id = c4s3['issue_place_id']&.to_i
            case c4s3['issue_method']
            when 'mfc'
              hub.os.addresses[office_id] || {}
            when 'institution'
              hub.mfc.ld_offices[office_id] || {}
            else
              {}
            end
          end
        end
      end
    end
  end
end
