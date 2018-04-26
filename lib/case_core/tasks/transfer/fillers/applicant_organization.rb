# frozen_string_literal: true

require_relative 'base/filler'

module CaseCore
  module Tasks
    class Transfer
      module Fillers
        # Класс объектов, заполняющих атрибуты заявки с информацией о
        # заявителе, который является юридическим лицом
        class ApplicantOrganizationOrganization < Base::Filler
          # Ассоциативный массив, в котором названиям полей записи
          # соответствуют названия атрибутов заявки
          NAMES = {
            full_name:
              'applicant_organization_full_name',
            short_name:
              'applicant_organization_short_name',
            ogrn:
              'applicant_organization_ogrn',
            bankname:
              'applicant_organization_bank_name',
            bik:
              'applicant_organization_bik',
            settlement_account:
              'applicant_organization_checking_account',
            correspondent_account:
              'applicant_organization_correspondent_account',
            inn:
              'applicant_organization_inn',
            kpp:
              'applicant_organization_kpp',
            registration_date:
              'applicant_organization_registry_date'
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
            hub.applicant_organization(applicant_id)
          end
        end
      end
    end
  end
end
