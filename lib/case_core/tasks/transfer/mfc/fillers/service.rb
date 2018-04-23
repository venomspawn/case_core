# frozen_string_literal: true

require_relative 'base/filler'

module CaseCore
  module Tasks
    class Transfer
      module MFC
        module Fillers
          # Класс объектов, заполняющих атрибуты заявки, которые относятся к
          # услуге
          class Service < Base::Filler
            # Инициализирует объект класса
            # @param [CaseCore::Tasks::Transfer::CaseCore::DB] _cm_db
            #   объект, предоставляющий доступ к `case_core`
            # @param [CaseCore::Tasks::Transfer::MFC::DB] mfc_db
            #   объект, предоставляющий доступ к `mfc`
            # @param [Hash] c4s3
            #   ассоциативный массив с информацией о заявке
            # @param [Hash] memo
            #   ассоциативный массив с атрибутами заявки
            def initialize(_cm_db, mfc_db, c4s3, memo)
              service = extract_service(mfc_db, c4s3, memo)
              super(service, memo)
            end

            private

            # Возвращает ассоциативный массив с информацией об услуге
            # @param [CaseCore::Tasks::Transfer::MFC::DB] mfc_db
            #   объект, предоставляющий доступ к `mfc`
            # @param [Hash] c4s3
            #   ассоциативный массив с информацией о заявке
            # @param [Hash] memo
            #   ассоциативный массив с атрибутами заявки
            # @return [Hash]
            #   результирующий ассоциативный массив
            def extract_service(mfc_db, c4s3, memo)
              target_service_rguid = c4s3['target_service_rguid']
              target_service = mfc_db.ld_target_services[target_service_rguid]
              target_service ||= {}
              service_id = target_service[:service_id]
              mfc_db.ld_services[service_id] || {}
            end

            # Ассоциативный массив, в котором названиям полей записи
            # соответствуют названия атрибутов заявки
            NAMES = { title: 'service_title', rguid: 'service_rguid' }.freeze

            # Возвращает ассоциативный массив, в котором названиям полей записи
            # соответствуют названия атрибутов заявки
            # @return [Hash]
            #   результирующий ассоциативный массив
            def names
              NAMES
            end
          end
        end
      end
    end
  end
end
