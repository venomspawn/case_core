# frozen_string_literal: true

module CaseCore
  need 'helpers/log'
  need 'tasks/transfer/extractors/case_attributes'
  need 'tasks/transfer/extractors/cases'
  need 'tasks/transfer/fillers/*'

  module Tasks
    class Transfer
      # Пространство имён класс объектов, импортирующих записи
      module Importers
        # Класс объектов, импортирующих записи заявок
        class Cases
          include CaseCore::Helpers::Log

          # Импортирует записи заявок
          # @param [CaseCore::Tasks::Transfer::DataHub] hub
          #   объект, предоставляющий доступ к данным
          def self.import(hub)
            new(hub).import
          end

          # Инициализирует объект класса
          # @param [CaseCore::Tasks::Transfer::DataHub] hub
          #   объект, предоставляющий доступ к данным
          def initialize(hub)
            @hub = hub
          end

          # Список полей записей заявок
          CASE_COLUMNS = Models::Case.columns

          # Список полей записей атрибутов заявок
          ATTR_COLUMNS = %i[case_id name value].freeze

          # Импортирует записи заявок
          def import
            Models::Case.import(CASE_COLUMNS, case_values)
            log_imported_cases(cases.size, binding)
            Models::CaseAttribute.import(ATTR_COLUMNS, case_attr_values)
            log_imported_case_attrs(case_attr_values.size, binding)
          end

          private

          # Объект, предоставляющий доступ к данным
          # @return [CaseCore::Tasks::Transfer::DataHub]
          #   объект, предоставляющий доступ к данным
          attr_reader :hub

          # Возвращает ассоциативный массив, в котором ключами являются
          # ассоциативные массивы с атрибутами записей заявок в `case_core`,
          # а значениями — ассоциативные массивы с атрибутами записей заявок
          # в `case_manager`
          # @return [Hash]
          #   результирующий ассоциативный массив
          def cases
            @cases ||= Extractors::Cases.extract(hub)
          end

          # Возвращает список списков значений полей записей заявок
          # @return [Array<Array>]
          #   результирующий список
          def case_values
            cases.keys.map { |h| h.values_at(*CASE_COLUMNS) }
          end

          # Классы объектов, заполняющих атрибуты заявки
          FILLER_CLASSES = Fillers
                           .constants
                           .map(&Fillers.method(:const_get))
                           .select { |c| c.is_a?(Class) }

          # Возвращает список списков значений полей записей атрибутов заявок
          # @return [Array<Array>]
          #   результирующий список
          def case_attr_values
            @case_attr_values ||=
              cases.values.each_with_object([]) do |c4s3, memo|
                attrs = Extractors::CaseAttributes.extract(c4s3)
                FILLER_CLASSES.each { |filler| filler.new(hub, attrs).fill }
                case_id = c4s3[:id]
                attrs.each { |name, value| memo << [case_id, name, value] }
              end
          end

          # Создаёт запись в журнале событий о том, что импортированы записи
          # заявок
          # @param [Integer] count
          #   количество импортированных записей заявок
          # @param [Binding] context
          #   контекст
          def log_imported_cases(count, context)
            log_info(context) { <<-MESSAGE }
              Импортированы записи заявок в количестве #{count}
            MESSAGE
          end

          # Создаёт запись в журнале событий о том, что импортированы атрибуты
          # заявок
          # @param [Integer] count
          #   количество импортированных атрибутов заявок
          # @param [Binding] context
          #   контекст
          def log_imported_case_attrs(count, context)
            log_info(context) { <<-MESSAGE }
              Импортированы атрибуты заявок в количестве #{count}
            MESSAGE
            Transfer.stats.keys.sort.each do |name|
              log_debug(context) { "#{name}: #{Transfer.stats[name]}" }
            end
            Transfer.stats.select { |_, v| v.zero? }.keys.sort.each do |name|
              log_debug(context) { "#{name}: zero" }
            end
          end
        end
      end
    end
  end
end
