# frozen_string_literal: true

require 'set'

require "#{$lib}/helpers/log"

require_relative 'transfer/case_manager'

module CaseCore
  module Tasks
    # Класс объектов, осуществляющих миграцию данных из `case_manager`
    class Transfer
      include Helpers::Log

      # Создаёт экземпляр класса и запускает миграцию данных
      def self.launch!
        new.launch!
      end

      # Запускает миграцию данных
      def launch!
        imported_cases = import_cases
        import_case_attributes(imported_cases)
      end

      private

      # Возвращает объект, предоставляющий возможность работы с базой данных
      # `case_manager`
      # @return [CaseCore::Tasks::Transfer::CaseManager]
      #   результирующий объект
      def case_manager
        @case_manager ||= CaseManager.new
      end

      # Импортирует записи заявок из `case_manager` и возвращает список
      # ассоциативных массивов с информацией об атрибутах импортированных
      # заявок
      # @return [Array<String>]
      #   список идентификаторов импортированных записей
      def import_cases
        values = collect_case_values
        Models::Case.import(%i[id type created_at], values)
        log_info(binding) { <<-MESSAGE }
          Импортированы записи заявок в количестве #{values.size}
        MESSAGE
        imported_ids = values.map(&:first)
        imported_ids = Set.new(imported_ids)
        case_manager.cases.select { |c4s3| imported_ids.include?(c4s3[:id]) }
      end

      # Возвращает список трёхэлементных списков с идентификаторами, типами и
      # временной меткой создания заявок
      # @return [Array<Array>]
      #   результирующий список
      def collect_case_values
        case_manager.cases.each_with_object([]) do |c4s3, memo|
          values = case_values(c4s3)
          memo << values unless values.nil?
        end
      end

      # Возвращает множество идентификаторов записей заявок, присутствующих в
      # базе `case_core`
      # @return [Set<String>]
      #   результирующее множество
      def current_case_ids
        @current_case_ids ||= Models::Case.select_map(:id)
      end

      # Ассоциативный массив, сопоставляющий типы заявок в `case_manager` типам
      # заявок в `case_core`
      CASE_TYPES = {
        'CaseManager::Models::NonAutomatedServiceCase' =>
          'mfc_case',
        'CaseManager::Models::MSPServiceCase' =>
          'msp_case',
        'CaseManager::Models::MVDServiceCase' =>
          'adm_offence_drugs_case',
        'CaseManager::Models::FSSPServiceCase' =>
          'fssp_case',
        'CaseManager::Models::CIKServiceCase' =>
          'ru_rtlabs_election_3_case'
      }

      # Возвращает трёхэлементный список с идентификатором, типом и временной
      # меткой создания заявки или `nil`, если запись заявки невозможно
      # импортировать
      # @param [Hash] c4s3
      #   ассоциативный массив с информацией о записи заявки
      # @return [Array<(String, String, Time)>]
      #   результирующий список
      # @return [NilClass]
      #   если запись заявки невозможно импортировать
      def case_values(c4s3)
        id, type, created_at = c4s3.values_at(:id, :case_type, :created_at)
        type = CASE_TYPES[type]
        if type.nil?
          log_warn(binding) { <<-MESSAGE }
            Тип `#{c4s3[:case_type]}` заявки с идентификатором записи `#{id}`
            не поддерживается
          MESSAGE
        elsif current_case_ids.include?(id)
          log_info(binding) { <<-MESSAGE }
            Запись заявки с идентификатором `#{id}` уже импортирована
          MESSAGE
        else
          [id, type, created_at]
        end
      end

      # Импортирует атрибуты заявок из `case_manager`
      # @param [Array<Hash>] imported_cases
      #   список ассоциативных массивов с информацией об атрибутах
      #   импортированных заявок
      def import_case_attributes(imported_cases)
        values = collect_attribute_values(imported_cases)
        Models::CaseAttribute.import(%i[case_id name value], values)
        log_info(binding) { <<-MESSAGE }
          Импортированы атрибуты заявок в количестве #{values.size}
        MESSAGE
      end

      # Возвращает список трёхэлементных списков с идентификаторами записей
      # заявок, названиями и значениями атрибутов
      # @param [Array<Hash>] imported_cases
      #   список ассоциативных массивов с информацией об атрибутах
      #   импортированных заявок
      # @return [Array<Array>]
      #   результирующий список
      def collect_attribute_values(imported_cases)
        imported_cases.each_with_object([], &method(:add_attribute_values))
      end

      # Названия исключаемых атрибутов
      EXCLUDED_NAMES = %i[id case_type created_at]

      # Добавляет информацию об атрибутах заявки в список
      # @param [Hash] c4s3
      #   ассоциативный массив с информацией об атрибутах заявки
      # @param [Array<Array>]
      #   список с информацией об атрибутах заявок
      def add_attribute_values(c4s3, memo)
        c4s3.each do |name, value|
          next if EXCLUDED_NAMES.include?(name) || value.nil?
          memo << case_attribute_values(c4s3, name, value)
        end
      end

      # Ассоциативный массив, сопоставляющий названиям атрибутов заявок в
      # `case_manager` новые названия
      NEW_NAMES = {
        service_id:                   :target_service_rguid,
        issue_location_type:          :issue_method,
        issue_location_id:            :issue_place_id,
        creator_person_id:            :operator_id,
        issuer_person_id:             :closed_operator_id,
        response_expected_at:         :planned_receiving_date,
        responded_at:                 :issuance_receiving_date,
        issued_at:                    :issuance_receipt_date,
        closed_at:                    :closed_date,
        docs_send_expected_at:        :planned_sending_date,
        issuance_expected_at:         :planned_issuance_date,
        rejecting_expected_at:        :planned_rejecting_date,
        docs_sent_at:                 :processing_sending_date,
        added_to_rejecting_at:        :rejecting_date,
        rejected_at:                  :rejecting_sending_date,
        processor_person_id:          :processing_operator_id,
        response_processor_person_id: :issuance_operator_id,
        rejector_person_id:           :closed_operator_id,
        back_office_id:               :packaging_place_id,
        spokesman_id:                 :agent_id,
        front_office_id:              :case_creation_place_id,
        reception_started_at:         :reception_start_date
      }

      # Список значений атрибута `issue_method`
      ISSUE_METHODS = %w[institution mfc email post other]

      # Возвращает трёхэлементный список с идентификатором записи заявки,
      # названием атрибута и значением атрибута
      # @param [Hash] c4s3
      #   ассоциативный массив с информацией об атрибутах заявки
      # @param [#to_s] name
      #   название атрибута
      # @param [Object] value
      #   значение атрибута
      def case_attribute_values(c4s3, name, value)
        name = NEW_NAMES[name] || name
        case name
        when :issue_method
          value = ISSUE_METHODS[value]
        when :added_to_pending_at
          name = if c4s3[:rejecting_sending_date].nil?
                   :pending_register_sending_date
                 else
                   :pending_rejecting_register_sending_date
                 end
          value = value.strftime('%FT%T')
        when :register_id
          name = if c4s3[:rejecting_sending_date].nil?
                   :pending_register_id
                 else
                   :pending_rejecting_register_id
                 end
        when :planned_receiving_date,
             :planned_sending_date,
             :planned_issuance_date,
             :planned_rejecting_date
          value = value.strftime('%F')
        when :closed_date,
             :processing_sending_date,
             :rejecting_date,
             :rejecting_sending_date,
             :reception_start_date
          value = value.strftime('%FT%T')
        end
        [c4s3[:id], name.to_s, value.to_s]
      end
    end
  end
end
