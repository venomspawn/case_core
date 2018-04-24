# frozen_string_literal: true

require_relative 'base/filler'

module CaseCore
  module Tasks
    class Transfer
      module MFC
        module Fillers
          # Класс объектов, заполняющих атрибуты заявки, которые относятся к
          # ведомству, в которое отправлен невостребованный результат оказания
          # услуги
          class PendingRejectingRegisterInstitution < Base::Filler
            # Инициализирует объект класса
            # @param [CaseCore::Tasks::Transfer::CaseCore::DB] cm_db
            #   объект, предоставляющий доступ к `case_core`
            # @param [CaseCore::Tasks::Transfer::MFC::DB] mfc_db
            #   объект, предоставляющий доступ к `mfc`
            # @param [Hash] c4s3
            #   ассоциативный массив с информацией о заявке
            # @param [Hash] memo
            #   ассоциативный массив с атрибутами заявки
            def initialize(cm_db, mfc_db, c4s3, memo)
              institution = extract_institution(cm_db, mfc_db, c4s3, memo)
              super(institution, memo)
            end

            private

            # Возвращает ассоциативный массив с информацией о ведомстве, в
            # которое был отправлен реестр передаваемой корреспонденции с
            # невостребованным результатом оказания услуги
            # @param [CaseCore::Tasks::Transfer::CaseCore::DB] cm_db
            #   объект, предоставляющий доступ к `case_core`
            # @param [CaseCore::Tasks::Transfer::MFC::DB] mfc_db
            #   объект, предоставляющий доступ к `mfc`
            # @param [Hash] c4s3
            #   ассоциативный массив с информацией о заявке
            # @param [Hash] memo
            #   ассоциативный массив с атрибутами заявки
            # @return [Hash]
            #   результирующий ассоциативный массив
            def extract_institution(cm_db, mfc_db, c4s3, memo)
              register_id = c4s3['pending_rejecting_register_number']&.to_i
              register = cm_db.registers[register_id] || {}
              institution_rguid = register[:institution_rguid]
              mfc_db.ld_institutions[institution_rguid] || {}
            end

            # Ассоциативный массив, в котором названиям полей записи
            # соответствуют названия атрибутов заявки
            NAMES = {
              title:  'pending_rejecting_register_institution_name'
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
