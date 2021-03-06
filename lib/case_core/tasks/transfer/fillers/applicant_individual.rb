# frozen_string_literal: true

require_relative 'base/filler'

module CaseCore
  module Tasks
    class Transfer
      module Fillers
        # Класс объектов, извлекающих атрибуты заявки, которые относятся к
        # заявителю, являющегося физическим лицом
        class ApplicantIndividual < Base::Filler
          # Ассоциативный массив, в котором названиям полей записи
          # соответствуют названия атрибутов заявки
          NAMES = {
            birth_date:  'applicant_individual_birthday',
            birth_place: 'applicant_individual_birthplace',
            last_name:   'applicant_individual_surname',
            middle_name: 'applicant_individual_middle_name',
            first_name:  'applicant_individual_name',
            snils:       'applicant_individual_snils',
            inn:         'applicant_individual_inn'
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
            hub.cab.ecm_people[applicant_id] || {}
          end
        end
      end
    end
  end
end
