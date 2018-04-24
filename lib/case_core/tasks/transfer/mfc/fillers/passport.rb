# frozen_string_literal: true

require_relative 'base/filler'

module CaseCore
  module Tasks
    class Transfer
      module MFC
        module Fillers
          # Класс объектов, заполняющих атрибуты заявки, которые относятся к
          # паспорту услуги
          class Passport < Base::Filler
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
              passport = extract_passport(mfc_db, c4s3, memo)
              super(passport, memo)
            end

            private

            # Возвращает ассоциативный массив с информацией о паспорте услуги
            # @param [CaseCore::Tasks::Transfer::MFC::DB] mfc_db
            #   объект, предоставляющий доступ к `mfc`
            # @param [Hash] c4s3
            #   ассоциативный массив с информацией о заявке
            # @param [Hash] memo
            #   ассоциативный массив с атрибутами заявки
            # @return [Hash]
            #   результирующий ассоциативный массив
            def extract_passport(mfc_db, c4s3, memo)
              target_service_rguid = c4s3['target_service_rguid']
              target_service = mfc_db.ld_target_services[target_service_rguid]
              target_service ||= {}
              service_id = target_service[:service_id]
              service = mfc_db.ld_services[:service_id] || {}
              passport_id = service[:passport_id]
              mfc_db.ld_passports[passport_id] || {}
            end

            # Ассоциативный массив, в котором названиям полей записи
            # соответствуют названия атрибутов заявки
            NAMES = {
              full_title: 'passport_title',
              rguid:      'passport_rguid'
            }.freeze

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
