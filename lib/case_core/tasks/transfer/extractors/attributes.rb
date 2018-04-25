# frozen_string_literal: true

module CaseCore
  module Tasks
    class Transfer
      module Extractors
        # Класс объектов, предоставляющих возможность извлечения информации
        # об атрибутах заявки для импорта
        class Attributes
          # Возвращает ассоциативный массив атрибутов заявки
          # @param [Hash] c4s3
          #   ассоциативный массив атрибутов записи заявки в `case_manager`
          # @return [Hash] c4s3
          #   результирующий ассоциативный массив
          def self.extract(c4s3)
            new(c4s3).extract
          end

          # Инициализирует объект класса
          # @param [Hash] c4s3
          #   ассоциативный массив атрибутов записи заявки в `case_manager`
          def initialize(c4s3)
            @c4s3 = c4s3
          end

          # Названия исключаемых атрибутов
          EXCLUDED_NAMES = %i[id case_type].freeze

          # Возвращает ассоциативный массив атрибутов заявки
          # @return [Hash] c4s3
          #   результирующий ассоциативный массив
          def extract
            c4s3.each_with_object({}) do |(name, value), memo|
              next if EXCLUDED_NAMES.include?(name) || value.nil?
              name = mend_name(name)
              value = mend_value(name, value)
              memo[name] = value
              Transfer.stats[name] ||= 0
              Transfer.stats[name] += 1
            end
          end

          private

          # Ассоциативный массив с информацией о заявке
          # @return [Hash]
          #   ассоциативный массив с информацией о заявке
          attr_reader :c4s3

          # Возвращает, был ли результат оказания услуги отправлен на возврат
          # @return [Boolean]
          #   был ли результат оказания услуги отправлен на возврат
          def rejected?
            c4s3[:rejecting_sending_date].present?
          end

          # Ассоциативный массив, сопоставляющий названиям атрибутов заявок в
          # `case_manager` новые названия
          NAMES = {
            created_at:                   'case_creation_date',
            service_id:                   'target_service_rguid',
            issue_location_type:          'issue_method',
            issue_location_id:            'issue_place_id',
            creator_person_id:            'operator_id',
            issuer_person_id:             'closed_operator_id',
            response_expected_at:         'planned_receiving_date',
            responded_at:                 'issuance_receiving_date',
            issued_at:                    'issuance_receipt_date',
            closed_at:                    'closed_date',
            docs_send_expected_at:        'planned_sending_date',
            issuance_expected_at:         'planned_issuance_date',
            rejecting_expected_at:        'planned_rejecting_date',
            docs_sent_at:                 'processing_sending_date',
            added_to_rejecting_at:        'rejecting_date',
            rejected_at:                  'rejecting_sending_date',
            processor_person_id:          'processing_operator_id',
            response_processor_person_id: 'issuance_operator_id',
            rejector_person_id:           'closed_operator_id',
            back_office_id:               'packaging_place_id',
            spokesman_id:                 'agent_id',
            front_office_id:              'case_creation_place_id',
            reception_started_at:         'reception_start_date'
          }.freeze

          # Возвращает новое название атрибута `added_to_pending_at`
          # @return [String]
          #   новое название атрибута `added_to_pending_at`
          def added_to_pending_at_name
            return 'pending_rejecting_register_sending_date' if rejected?
            'pending_register_sending_date'
          end

          # Возвращает новое название атрибута `register_id`
          # @return [String]
          #   новое название атрибута `register_id`
          def register_id_name
            return 'pending_rejecting_register_number' if rejected?
            'pending_register_number'
          end

          # Возвращает новое название атрибута
          # @param [String] name
          #   исходное название атрибута
          def mend_name(name)
            name = NAMES[name] || name
            case name
            when :added_to_pending_at then added_to_pending_at_name
            when :register_id         then register_id_name
            else name.to_s
            end
          end

          # Ассоциативный массив значений атрибута `issue_method`
          ISSUE_METHODS = {
            1 => 'institution',
            2 => 'mfc',
            3 => 'email',
            4 => 'post',
            5 => 'other'
          }.freeze

          # Названия атрибутов, чьи значения должны представлять дату
          ATTR_DATES = %w[
            planned_receiving_date
            planned_sending_date
            planned_issuance_date
            planned_rejecting_date
          ].freeze

          # Названия атрибутов, чьи значения должны представлять дату и время
          ATTR_TIMES = %w[
            case_creation_date
            closed_date
            pending_register_sending_date
            pending_rejecting_register_sending_date
            processing_sending_date
            rejecting_date
            rejecting_sending_date
            reception_start_date
          ].freeze

          # Возвращает значение атрибута заявки
          # @param [Symbol] name
          #   исходное название атрибута
          # @param [Object] value
          #   исходное значение атрибута
          def mend_value(name, value)
            return ISSUE_METHODS[value]    if name == 'issue_method'
            return value.strftime('%F')    if ATTR_DATES.include?(name)
            return value.strftime('%FT%T') if ATTR_TIMES.include?(name)
            value
          end
        end
      end
    end
  end
end
