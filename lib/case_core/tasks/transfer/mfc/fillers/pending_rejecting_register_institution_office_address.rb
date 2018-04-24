# frozen_string_literal: true

require_relative 'base/filler'

module CaseCore
  module Tasks
    class Transfer
      module MFC
        module Fillers
          # Класс объектов, заполняющих атрибуты заявки, которые относятся к
          # адресу офиса ведомства, в которое отправлен невостребованный
          # результат оказания услуги
          class PendingRegisterInstitutionOfficeAddress < Base::Filler
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
              address = extract_address(cm_db, mfc_db, c4s3, memo)
              super(address, memo)
            end

            private

            # Возвращает ассоциативный массив с информацией о об адресе офиса
            # ведомства, в которое был отправлен реестр передаваемой
            # корреспонденции с невостребованным результатом оказания услуги
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
            def extract_address(cm_db, mfc_db, c4s3, memo)
              register_id = c4s3['pending_register_number']&.to_i
              register = cm_db.registers[register_id] || {}
              office_id = register[:office_id]&.to_i
              mend_address(mfc_db.ld_addresses[office_id] || {})
            end

            # Ассоциативный массив, в котором названиям полей записи
            # соответствуют названия атрибутов заявки
            NAMES = {
              :zip =>
                'pending_rejecting_register_institution_office_index',
              :country =>
                'pending_rejecting_register_institution_office_country_name',
              :region =>
                'pending_rejecting_register_institution_office_region_name',
              :district =>
                'pending_rejecting_register_institution_office_district',
              :city =>
                'pending_rejecting_register_institution_office_city',
              :settlement =>
                'pending_rejecting_register_institution_office_settlement',
              :street =>
                'pending_rejecting_register_institution_office_street',
              :house =>
                'pending_rejecting_register_institution_office_house',
              :building =>
                'pending_rejecting_register_institution_office_building',
              :appartment =>
                'pending_rejecting_register_institution_office_room'
            }.freeze

            # Возвращает ассоциативный массив, в котором названиям полей записи
            # соответствуют названия атрибутов заявки
            # @return [Hash]
            #   результирующий ассоциативный массив
            def names
              NAMES
            end

            # Дополняет атрибутами ассоциативный массив с информацией об адресе
            # и возвращает его
            # @param [Hash] addr
            #   ассоциативный массив с информацией об адресе
            # @return [Hash]
            #   ассоциативный массив с информацией об адресе
            def mend_address(addr)
              addr.tap do
                region = addr[:okrug] || addr[:federal_subject]
                addr[:region] = region unless region.blank?

                district = addr[:town_area] || addr[:area]
                addr[:district] = district unless district.blank?

                settlement = addr[:town] || addr[:city_area]
                addr[:settlement] = settlement unless settlement.blank?
              end
            end
          end
        end
      end
    end
  end
end
