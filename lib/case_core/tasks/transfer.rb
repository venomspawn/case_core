# frozen_string_literal: true

require "#{$lib}/helpers/log"

require_relative 'transfer/data_hub'
require_relative 'transfer/extractors/attributes'
require_relative 'transfer/extractors/cases'

Dir["#{__dir__}/transfer/fillers/*.rb"].each(&method(:require))

module CaseCore
  module Tasks
    # Класс объектов, осуществляющих миграцию данных из `case_manager`
    class Transfer
      include Helpers::Log

      # Возвращает ассоциативный массив со статистикой по импортированным
      # атрибутам
      # @return [Hash]
      #   ассоциативный массив со статистикой по импортированным атрибутам
      def self.stats
        @stats ||= {}
      end

      # Создаёт экземпляр класса и запускает миграцию данных
      def self.launch!
        new.launch!
      end

      # Запускает миграцию данных
      def launch!
        @hub = DataHub.new
        import_cases
      end

      private

      # Объект, предоставляющий доступ к данным
      # @return [CaseCore::Tasks::Transfer::DataHub]
      #   объект, предоставляющий доступ к данным
      attr_reader :hub

      # Названия атрибутов испортируемых записей заявок
      CASE_ATTRS = %i[id type created_at]

      # Импортирует записи заявок из `case_manager` и возвращает список
      # ассоциативных массивов с информацией об атрибутах импортированных
      # заявок
      # @return [Array<String>]
      #   список идентификаторов импортированных записей
      def import_cases
        extracted_cases = Extractors::Cases.extract(hub)
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

      # Классы объектов, заполняющих атрибуты заявки
      FILLER_CLASSES = Fillers
                       .constants
                       .map(&Fillers.method(:const_get))
                       .select { |c| c.is_a?(Class) }

      # Возвращает список списков значений полей записей атрибутов заявок
      # @param [Array<Hash>] imported_cases
      #   список ассоциативных массивов с информацией об атрибутах
      #   импортированных заявок
      # @return [Array]
      #   результирующий список
      def case_attribute_values(imported_cases)
        imported_cases.each_with_object([]) do |c4s3, memo|
          attributes = Extractors::Attributes.extract(c4s3)
          FILLER_CLASSES.each { |filler| filler.new(hub, attributes).fill }
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
        Transfer.stats.keys.sort.each do |name|
          log_debug(context) { "#{name}: #{Transfer.stats[name]}" }
        end
      end
    end
  end
end
