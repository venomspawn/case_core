# frozen_string_literal: true

require_relative 'base/filler'

module CaseCore
  module Tasks
    class Transfer
      module Fillers
        # Класс объектов, заполняющих атрибуты заявки с информацией о
        # документе, удостоверяющем личность представителя
        class AgentIndividualIdentityDoc < Base::Filler
          # Ассоциативный массив, в котором названиям полей записи
          # соответствуют названия атрибутов заявки
          NAMES = {
            'ser'     => 'agent_individual_identity_doc_series',
            'nom'     => 'agent_individual_identity_doc_number',
            'kemvid'  => 'agent_individual_identity_doc_issued_by',
            'datavid' => 'agent_individual_identity_doc_issue_date',
            'deys'    => 'agent_individual_identity_doc_expiration_end',
            'type'    => 'agent_individual_identity_doc_type'
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
            agent_id = c4s3['agent_id']
            hub.applicant_identity_doc_content(agent_id)
          end
        end
      end
    end
  end
end
