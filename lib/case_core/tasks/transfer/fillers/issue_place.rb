# frozen_string_literal: true

require_relative 'base/filler'

module CaseCore
  module Tasks
    class Transfer
      module Fillers
        # Класс объектов, извлекающих атрибуты заявки, которые относятся к
        # месту выдачи заявки
        class IssuePlace < Base::Filler
          # Ассоциативный массив, в котором названиям полей записи
          # соответствуют названия атрибутов заявки
          NAMES = {
            name:  'issue_place_name',
            title: 'issue_place_name'
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
            case c4s3['issue_method']
            when 'mfc'
              office_id = c4s3['issue_place_id']&.to_i
              hub.os.offices[office_id] || {}
            when 'institution'
              institution_rguid = c4s3['institution_rguid']
              hub.mfc.ld_institutions[institution_rguid] || {}
            else
              {}
            end
          end
        end
      end
    end
  end
end
