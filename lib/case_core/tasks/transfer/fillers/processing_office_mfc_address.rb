# frozen_string_literal: true

require_relative 'base/filler'

module CaseCore
  module Tasks
    class Transfer
      module Fillers
        # Класс объектов, извлекающих атрибуты заявки, которые относятся к
        # адресу места отправления реестра передаваемой корреспонденции с
        # документами заявки на обработку
        class ProcessingPlaceAddress < Base::Filler
          # Ассоциативный массив, в котором названиям полей записи
          # соответствуют названия атрибутов заявки
          NAMES = {
            zip:        'processing_office_mfc_index',
            country:    'processing_office_mfc_country_name',
            region:     'processing_office_mfc_region_name',
            sub_region: 'processing_office_mfc_district',
            city:       'processing_office_mfc_city',
            settlement: 'processing_office_mfc_settlement',
            street:     'processing_office_mfc_street',
            house:      'processing_office_mfc_house',
            building:   'processing_office_mfc_building',
            appartment: 'processing_office_mfc_room'
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
            operator_id = c4s3['processing_operator_id']
            hub.operator_office_address(operator_id)
          end
        end
      end
    end
  end
end
