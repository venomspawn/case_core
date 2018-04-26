# frozen_string_literal: true

require_relative 'base/filler'

module CaseCore
  module Tasks
    class Transfer
      module Fillers
        # Класс объектов, заполняющих атрибуты заявки с информацией о
        # доверенности представителя
        class AgentVicariousAuthority < Base::Filler
          # Ассоциативный массив, в котором названиям полей записи
          # соответствуют названия атрибутов заявки
          NAMES = {
            'ser'             => 'agent_vicarious_authority_series',
            'nom'             => 'agent_vicarious_authority_number',
            'kemvid'          => 'agent_vicarious_authority_issued_by',
            'datavid'         => 'agent_vicarious_authority_issue_date',
            'deys'            => 'agent_vicarious_authority_expiration_date',
            'title'           => 'agent_vicarious_authority_title',
            'registry_number' => 'agent_vicarious_authority_registry_number'
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
            agent_id = c4s3['agent_id']
            key = [applicant_id, agent_id]
            document = hub.cab.vicarious_authorities[key] || {}
            document[:content] || {}
          end
        end
      end
    end
  end
end
