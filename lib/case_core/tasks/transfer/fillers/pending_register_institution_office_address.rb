# frozen_string_literal: true

require_relative 'base/filler'

module CaseCore
  module Tasks
    class Transfer
      module Fillers
        # Класс объектов, заполняющих атрибуты заявки, которые относятся к
        # адресу офиса ведомства, в которое отправлены документы заявки для
        # обработки
        class PendingRegisterInstitutionOfficeAddress < Base::Filler
          # Ассоциативный массив, в котором названиям полей записи
          # соответствуют названия атрибутов заявки
          NAMES = {
            zip:        'pending_register_institution_office_index',
            country:    'pending_register_institution_office_country_name',
            region:     'pending_register_institution_office_region_name',
            district:   'pending_register_institution_office_district',
            city:       'pending_register_institution_office_city',
            settlement: 'pending_register_institution_office_settlement',
            street:     'pending_register_institution_office_street',
            house:      'pending_register_institution_office_house',
            building:   'pending_register_institution_office_building',
            appartment: 'pending_register_institution_office_room'
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
            register_id = c4s3['pending_register_number']&.to_i
            hub.register_office_address(register_id)
          end
        end
      end
    end
  end
end
