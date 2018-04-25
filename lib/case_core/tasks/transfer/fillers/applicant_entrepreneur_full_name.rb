# frozen_string_literal: true

require_relative 'base/filler'

module CaseCore
  module Tasks
    class Transfer
      module Fillers
        # Класс объектов, заполняющих атрибут заявки, который содержит в себе
        # полное имя заявителя, являющегося индивидуальным предпринимателем
        class ApplicantEntrepreneurFullName < Base::Filler
          # Ассоциативный массив, в котором названиям полей записи
          # соответствуют названия атрибутов заявки
          NAMES = { full_name: 'applicant_entrepreneur_full_name' }.freeze

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
            { full_name: hub.applicant_full_name(applicant_id) }
          end
        end
      end
    end
  end
end
