# frozen_string_literal: true

require_relative 'base/filler'

module CaseCore
  module Tasks
    class Transfer
      module Fillers
        # Класс объектов, заполняющих атрибуты заявки с информацией о
        # представителе как о физическом лице
        class AgentIndividual < Base::Filler
          # Ассоциативный массив, в котором названиям полей записи
          # соответствуют названия атрибутов заявки
          NAMES = {
            birth_date:  'agent_individual_birthday',
            birth_place: 'agent_individual_birthplace',
            last_name:   'agent_individual_surname',
            middle_name: 'agent_individual_middle_name',
            first_name:  'agent_individual_name',
            inn:         'agent_individual_inn',
            snils:       'agent_individual_snils'
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
            hub.cab.ecm_people[agent_id] || {}
          end
        end
      end
    end
  end
end
