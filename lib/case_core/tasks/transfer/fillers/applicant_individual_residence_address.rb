# frozen_string_literal: true

require_relative 'base/filler'

module CaseCore
  module Tasks
    class Transfer
      module Fillers
        # Класс объектов, извлекающих атрибуты заявки, которые относятся к
        # адресу места проживания заявителя, являющегося физическим лицом
        class ApplicantIndividualResidenceAddress < Base::Filler
          # Ассоциативный массив, в котором названиям полей записи
          # соответствуют названия атрибутов заявки
          NAMES = {
            zip:        'applicant_individual_residence_index',
            country:    'applicant_individual_residence_country_name',
            region:     'applicant_individual_residence_region_name',
            sub_region: 'applicant_individual_residence_district',
            city:       'applicant_individual_residence_city',
            settlement: 'applicant_individual_residence_settlement',
            street:     'applicant_individual_residence_street',
            house:      'applicant_individual_residence_house',
            building:   'applicant_individual_residence_building',
            appartment: 'applicant_individual_residence_room'
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
            return {} unless hub.applicant_individual?(applicant_id)
            hub.cab.ecm_factual_addresses[applicant_id] || {}
          end
        end
      end
    end
  end
end
