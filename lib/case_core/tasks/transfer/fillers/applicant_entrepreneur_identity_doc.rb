# frozen_string_literal: true

require_relative 'base/filler'

module CaseCore
  module Tasks
    class Transfer
      module Fillers
        # Класс объектов, заполняющих атрибуты заявки с информацией о
        # документе, удостоверяющем личность заявителя, который является
        # индивидуальным предпринимателем
        class ApplicantEntrepreneurIdentityDoc < Base::Filler
          # Ассоциативный массив, в котором названиям полей записи
          # соответствуют названия атрибутов заявки
          NAMES = {
            'ser'     => 'applicant_entrepreneur_identity_doc_series',
            'nom'     => 'applicant_entrepreneur_identity_doc_number',
            'kemvid'  => 'applicant_entrepreneur_identity_doc_issued_by',
            'datavid' => 'applicant_entrepreneur_identity_doc_issue_date',
            'deys'    => 'applicant_entrepreneur_identity_doc_expiration_end',
            'type'    => 'applicant_entrepreneur_identity_doc_type'
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
            hub.applicant_identity_doc_content(applicant_id)
          end
        end
      end
    end
  end
end
