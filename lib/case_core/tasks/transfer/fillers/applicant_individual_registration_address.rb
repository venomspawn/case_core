# frozen_string_literal: true

require_relative 'base/filler'

module CaseCore
  module Tasks
    class Transfer
      module Fillers
        # Класс объектов, извлекающих атрибуты заявки, которые относятся к
        # адресу регистрации заявителя, являющегося физическим лицом
        class ApplicantIndividualRegistrationAddress < Base::Filler
          # Ассоциативный массив, в котором названиям полей записи
          # соответствуют названия атрибутов заявки
          NAMES = {
            zip:        'applicant_individual_registration_index',
            country:    'applicant_individual_registration_country_name',
            region:     'applicant_individual_registration_region_name',
            sub_region: 'applicant_individual_registration_district',
            city:       'applicant_individual_registration_city',
            settlement: 'applicant_individual_registration_settlement',
            street:     'applicant_individual_registration_street',
            house:      'applicant_individual_registration_house',
            building:   'applicant_individual_registration_building',
            appartment: 'applicant_individual_registration_room'
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
            hub.cab.ecm_addresses[applicant_id] || {}
          end
        end
      end
    end
  end
end
