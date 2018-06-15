# frozen_string_literal: true

require_relative 'base/filler'

module CaseCore
  module Tasks
    class Transfer
      module Fillers
        # Класс объектов, заполняющих атрибуты заявки с информацией о
        # контактных данных заявителя, который является индивидуальным
        # предпринимателем
        class ApplicantEntrepreneurContacts < Base::Filler
          # Ассоциативный массив, в котором названиям полей записи
          # соответствуют названия атрибутов заявки
          NAMES = {
            fax:   'applicant_entrepreneur_fax',
            site:  'applicant_entrepreneur_site',
            email: 'applicant_entrepreneur_email',
            phone: 'applicant_entrepreneur_phone_number'
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
            return {} unless hub.applicant_entrepreneur?(applicant_id)
            hub.cab.ecm_contacts[applicant_id] || {}
          end
        end
      end
    end
  end
end
