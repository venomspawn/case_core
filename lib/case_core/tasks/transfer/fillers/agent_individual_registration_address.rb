# frozen_string_literal: true

require_relative 'base/filler'

module CaseCore
  module Tasks
    class Transfer
      module Fillers
        # Класс объектов, извлекающих атрибуты заявки, которые относятся к
        # адресу регистрации представителя
        class AgentIndividualRegistrationAddress < Base::Filler
          # Ассоциативный массив, в котором названиям полей записи
          # соответствуют названия атрибутов заявки
          NAMES = {
            zip:        'agent_individual_registration_index',
            country:    'agent_individual_registration_country_name',
            region:     'agent_individual_registration_region_name',
            sub_region: 'agent_individual_registration_district',
            city:       'agent_individual_registration_city',
            settlement: 'agent_individual_registration_settlement',
            street:     'agent_individual_registration_street',
            house:      'agent_individual_registration_house',
            building:   'agent_individual_registration_building',
            appartment: 'agent_individual_registration_room'
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
            hub.cab.ecm_addresses[agent_id] || {}
          end
        end
      end
    end
  end
end
