# frozen_string_literal: true

require_relative 'base/filler'

module CaseCore
  module Tasks
    class Transfer
      module Fillers
        # Класс объектов, заполняющих атрибуты заявки с информацией о
        # заявителе, который является индивидуальным предпринимателем
        class ApplicantEntrepreneurOrganization < Base::Filler
          # Ассоциативный массив, в котором названиям полей записи
          # соответствуют названия атрибутов заявки
          NAMES = {
            full_name:
              'applicant_entrepreneur_business_name',
            ogrnip:
              'applicant_entrepreneur_ogrn',
            bankname:
              'applicant_entrepreneur_bank_name',
            bik:
              'applicant_entrepreneur_bik',
            settlement_account:
              'applicant_entrepreneur_checking_account',
            correspondent_account:
              'applicant_entrepreneur_correspondent_account',
            inn:
              'applicant_entrepreneur_inn'
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
            hub.applicant_organization(applicant_id)
          end
        end
      end
    end
  end
end
