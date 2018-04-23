# frozen_string_literal: true

require_relative 'base/filler'

module CaseCore
  module Tasks
    class Transfer
      module Fillers
        # Класс объектов, извлекающих атрибуты заявки, которые относятся к
        # адресу офиса МФЦ, в котором заявке выставлен статус `issuance`
        class IssuanceOfficeMFCAddress < Base::Filler
          # Ассоциативный массив, в котором названиям полей записи
          # соответствуют названия атрибутов заявки
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

          private

          # Возвращает ассоциативный массив полей записи
          # @param [CaseCore::Tasks::Transfer::DataHub] hub
          #   объект, предоставляющий доступ к данным
          # @param [Hash] c4s3
          #   ассоциативный массив с информацией о заявке
          # @return [Hash]
          #   ассоциативный массив полей записи
          def extract_record(hub, c4s3)
            operator_id = c4s3['issuance_operator_id']
            hub.operator_office_address(operator_id)
          end
        end
      end
    end
  end
end
