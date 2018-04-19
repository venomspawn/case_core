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
        import_cases
      end

      private

      # Возвращает объект, предоставляющий возможность работы с базой данных
      # `case_manager`
      # @return [CaseCore::Tasks::Transfer::CaseManager]
      #   результирующий объект
      def case_manager
        @case_manager ||= CaseManager.new
      end

      # Импортирует записи заявок из `case_manager`
      def import_cases
        values = collect_case_values
        Models::Case.import(%i[id type created_at], values)
        log_info(binding) { <<-MESSAGE }
          Импортированы записи заявок в количестве #{values.size}
        MESSAGE
      end

      # Возвращает список трёхэлементных списков с идентификаторами, типами и
      # временной меткой создания заявок
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
    end
  end
end
