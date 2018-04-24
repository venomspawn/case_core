# frozen_string_literal: true

require "#{$lib}/helpers/log"

require_relative 'transfer/case_manager'
require_relative 'transfer/mfc'
require_relative 'transfer/org_struct'

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
      # @return [CaseCore::Tasks::Transfer::CaseManager::DB]
      #   результирующий объект
      def cm_db
        @cm_db ||= CaseManager::DB.new
      end

      # Возвращает объект, предоставляющий возможность работы с базой данных
      # `mfc`
      # @return [CaseCore::Tasks::Transfer::MFC::DB]
      #   результирующий объект
      def mfc_db
        @mfc_db ||= MFC::DB.new
      end

      # Возвращает объект, предоставляющий возможность работы с базой данных
      # `org_struct`
      # @return [CaseCore::Tasks::Transfer::OrgStruct::DB]
      #   результирующий объект
      def os_db
        @os_db ||= OrgStruct::DB.new
      end

      # Названия атрибутов испортируемых записей заявок
      CASE_ATTRS = %i[id type created_at]

      # Импортирует записи заявок из `case_manager` и возвращает список
      # ассоциативных массивов с информацией об атрибутах импортированных
      # заявок
      # @return [Array<String>]
      #   список идентификаторов импортированных записей
      def import_cases
        extracted_cases = CaseManager::Extractors::Cases.extract(cm_db)
        values = extracted_cases.keys.map { |h| h.values_at(*CASE_ATTRS) }
        Models::Case.import(CASE_ATTRS, values)
        log_imported_cases(values.size, binding)
        import_case_attributes(extracted_cases.values)
      end

      # Создаёт запись в журнале событий о том, что импортированы записи заявок
      # @param [Integer] count
      #   количество импортированных записей заявок
      # @param [Binding] context
      #   контекст
      def log_imported_cases(count, context)
        log_info(context) { <<-MESSAGE }
          Импортированы записи заявок в количестве #{count}
        MESSAGE
      end

      # Импортирует атрибуты заявок из `case_manager`
      # @param [Array<Hash>] imported_cases
      #   список ассоциативных массивов с информацией об атрибутах
      #   импортированных заявок
      def import_case_attributes(imported_cases)
        values = case_attribute_values(imported_cases)
        Models::CaseAttribute.import(%i[case_id name value], values)
        log_imported_case_attributes(values.size, binding)
      end

      # Возвращает список списков значений полей записей атрибутов заявок
      # @param [Array<Hash>] imported_cases
      #   список ассоциативных массивов с информацией об атрибутах
      #   импортированных заявок
      # @return [Array]
      #   результирующий список
      def case_attribute_values(imported_cases)
        imported_cases.each_with_object([]) do |c4s3, memo|
          attributes = CaseManager::Extractors::Attributes.extract(c4s3)
          MFC.fill(cm_db, mfc_db, attributes, attributes)
          OrgStruct.fill(os_db, mfc_db, attributes, attributes)
          case_id = c4s3[:id]
          attributes.each { |name, value| memo << [case_id, name, value] }
        end
      end

      # Создаёт запись в журнале событий о том, что импортированы атрибуты
      # заявок
      # @param [Integer] count
      #   количество импортированных атрибутов заявок
      # @param [Binding] context
      #   контекст
      def log_imported_case_attributes(count, context)
        log_info(context) { <<-MESSAGE }
          Импортированы атрибуты заявок в количестве #{count}
        MESSAGE
      end
    end
  end
end
