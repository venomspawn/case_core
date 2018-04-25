# frozen_string_literal: true

require_relative 'base/filler'

module CaseCore
  module Tasks
    class Transfer
      module Fillers
        # Класс объектов, заполняющих атрибут заявки, который сигнализирует о
        # типе заявителя
        class ApplicantType < Base::Filler
          # Ассоциативный массив, в котором названиям полей записи
          # соответствуют названия атрибутов заявки
          NAMES = { applicant_type: 'applicant_type' }.freeze

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
            if hub.applicant_individual?(applicant_id)
              { applicant_type: 'invdividual' }
            elsif hub.applicant_entrepreneur?(applicant_id)
              { applicant_type: 'entrepreneur' }
            elsif hub.applicant_organization?(applicant_id)
              { applicant_type: 'organization' }
            else
              {}
            end
          end
        end
      end
    end
  end
end
