# frozen_string_literal: true

require "#{$lib}/helpers/log"

module CaseCore
  module Tasks
    class Transfer
      # Вспомогательный модуль, предназначенный для подключения к содержащему
      # классу
      module Helpers
        include CaseCore::Helpers::Log

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
        def log_imported_case_attributes(count, context)
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

        # Создаёт запись в журнале событий о том, что импортированы записи
        # документов
        # @param [Integer] count
        #   количество импортированных записей документов
        # @param [Binding] context
        #   контекст
        def log_imported_documents(count, context)
          log_info(context) { <<-MESSAGE }
            Импортированы записи документов в количестве #{count}
          MESSAGE
        end

        # Создаёт запись в журнале событий о том, что импортированы записи
        # межведомственных запросов
        # @param [Integer] count
        #   количество импортированных записей межведомственных запросов
        # @param [Binding] context
        #   контекст
        def log_imported_requests(count, context)
          log_info(context) { <<-MESSAGE }
            Импортированы записи межведомственных запросов в количестве
            #{count}
          MESSAGE
        end

        # Создаёт запись в журнале событий о том, что импортированы атрибуты
        # межведомственных запросов
        # @param [Integer] count
        #   количество импортированных атрибутов межведомственных запросов
        # @param [Binding] context
        #   контекст
        def log_imported_request_attributes(count, context)
          log_info(context) { <<-MESSAGE }
            Импортированы атрибуты межведомственных запросов в количестве
            #{count}
          MESSAGE
        end

        # Создаёт запись в журнале событий о том, что импортированы реестры
        # передаваемой корреспонденции
        # @param [Integer] count
        #   количество импортированных реестров
        # @param [Binding] context
        #   контекст
        def log_imported_registers(count, context)
          log_info(context) { <<-MESSAGE }
            Импортированы реестры передаваемой корреспонденции в количестве
            #{count}
          MESSAGE
        end
      end
    end
  end
end
