# frozen_string_literal: true

require_relative 'base/filler'

module CaseCore
  module Tasks
    class Transfer
      module Fillers
        # Класс объектов, извлекающих атрибуты заявки, которые относятся к
        # адресу места проживания заявителя, являющегося юридическим лицом
        class ApplicantOrganizationActualAddress < Base::Filler
          # Ассоциативный массив, в котором названиям полей записи
          # соответствуют названия атрибутов заявки
          NAMES = {
            zip:        'applicant_organization_actual_index',
            region:     'applicant_organization_actual_region_name',
            sub_region: 'applicant_organization_actual_district',
            city:       'applicant_organization_actual_city',
            settlement: 'applicant_organization_actual_settlement',
            street:     'applicant_organization_actual_street',
            house:      'applicant_organization_actual_house',
            building:   'applicant_organization_actual_building',
            appartment: 'applicant_organization_actual_room'
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
            applicant_id = c4s3['applicant_id']
            return {} unless hub.applicant_organization?(applicant_id)
            hub.cab.ecm_factual_addresses[applicant_id] || {}
          end
        end
      end
    end
  end
end
