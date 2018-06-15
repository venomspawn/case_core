# frozen_string_literal: true

require_relative 'base/filler'

module CaseCore
  module Tasks
    class Transfer
      module Fillers
        # Класс объектов, заполняющих атрибуты заявки, которые относятся к
        # офису ведомства, в которое отправлен невостребованный результат
        # оказания услуги
        class PendingRejectingRegisterInstitutionOffice < Base::Filler
          # Ассоциативный массив, в котором названиям полей записи
          # соответствуют названия атрибутов заявки
          NAMES = {
            name: 'pending_rejecting_register_institution_office_name'
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
            register_id = c4s3['pending_rejecting_register_number']&.to_i
            hub.register_office(register_id)
          end
        end
      end
    end
  end
end
