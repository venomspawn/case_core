# frozen_string_literal: true

require "#{$lib}/helpers/log"
require "#{$lib}/helpers/safe_call"

require_relative 'errors'

module CaseCore
  module Logic
    class Loader
      # Вспомогательный модуль, предназначенный для включения в содержащий
      # класс
      module Helpers
        include CaseCore::Helpers::Log
        include CaseCore::Helpers::SafeCall

        # Проверяет, что модуль был найден
        # @param [String] name
        #   название модуля в змеином_регистре
        # @param [String] filename
        #   путь к файлу с модулем
        # @param [NilClass, Module] logic_module
        #   найденный модуль или `nil`, если модуль не был найден
        # @raise [CaseCore::Logic::Loader::Errors::LogicModule::NotFound]
        #   если модуль не был найден
        def check_if_logic_module_is_found!(name, filename, logic_module)
          return unless logic_module.nil?
          raise Errors::LogicModule::NotFound.new(name, filename)
        end

        # Проверяет, что модуль был найден среди загруженных по
        # предоставленному название
        # @param [#to_s] name
        #   название
        # @param [String] module_name
        #   название найденного модуля бизнес-логики
        # @raise [CaseCore::Logic::Loader::Errors::LogicModule::NotFoundByName]
        #   если модуль не был найден
        def check_if_logic_module_is_found_by_name!(name, module_name)
          return unless module_name.empty?
          raise Errors::LogicModule::NotFoundByName, name
        end

        # Создаёт запись в журнале событий о том, что во время загрузки модуля
        # с данным названием произошла ошибка
        # @param [String] name
        #   название модуля в змеином_регистре
        # @param [Exception] err
        #   объект с информацией об ошибке
        # @param [Binding] context
        #   контекст
        def log_load_module_error(name, err, context)
          log_error(context) { <<-LOG }
            Во время загрузки модуля с названием #{name} произошла ошибка
            `#{err.class}`: `#{err.message}`
          LOG
        end

        # Создаёт новую запись в журнале событий о том, что у модуля
        # бизнес-логики отсутствует функция с данным именем
        # @param [Module] logic
        #   модуль бизнес-логики
        # @param [#to_s] func_name
        #   название функции
        # @param [Binding] context
        #   контекст
        def log_no_func(logic, func_name, context)
          log_debug(context) { <<-LOG }
            У модуля бизнес-логики `#{logic}` отсутствует функция
            `#{func_name}`
          LOG
        end

        # Создаёт новую запись в журнале событий о том, что при вызове функции
        # у модуля бизнес-логики произошла ошибка
        # @param [Exception] err
        #   объект с информацией об ошибке
        # @param [Module] logic
        #   модуль бизнес-логики
        # @param [#to_s] func_name
        #   название функции
        # @param [Binding] context
        #   контекст
        def log_func_error(err, logic, func_name, context)
          log_error(context) { <<-LOG }
            При вызове функции `#{func_name}` модуля бизнес-логики `#{logic}`
            произошла ошибка `#{err.class}`: `#{err.message}`
          LOG
        end
      end
    end
  end
end
