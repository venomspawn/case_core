# frozen_string_literal: true

require_relative 'errors'

module CaseCore
  need 'helpers/log'
  need 'helpers/safe_call'

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
        # у модуля бизнес-логики произошла ошибка или что ошибки не произошло
        # @param [NilClass, Exception] err
        #   объект с информацией об ошибке или `nil`, если ошибки не произошло
        # @param [Module] logic
        #   модуль бизнес-логики
        # @param [#to_s] func_name
        #   название функции
        # @param [Binding] context
        #   контекст
        def log_func_call(err, logic, func_name, context)
          return log_debug(context) { <<-LOG } if err.nil?
            Успешно вызвана функция `#{func_name}` модуля бизнес-логики
            `#{logic}`
          LOG
          log_error(context) { <<-LOG }
            При вызове функции `#{func_name}` модуля бизнес-логики `#{logic}`
            произошла ошибка `#{err.class}`: `#{err.message}`
          LOG
        end

        # Создаёт новую запись в журнале событий о том, что модуль
        # бизнес-логики выгружается из памяти
        # @param [CaseCore::Logic::Loader::ModuleInfo] module_info
        #   объект с информацией о модуле бизнес-логики
        # @param [Binding] context
        #   контекст
        def log_unload_module(module_info, context)
          log_info(context) { <<-LOG }
            Выгружен из памяти модуль бизнес-логики
            `#{module_info.logic_module}` версии `#{module_info.version}`,
            который был загружен #{module_info.time}
          LOG
        end

        # Создаёт новую запись в журнале событий о том, что модуль
        # бизнес-логики загружен
        # @param [CaseCore::Logic::Loader::ModuleInfo] module_info
        #   объект с информацией о модуле бизнес-логики
        # @param [Binding] context
        #   контекст
        def log_load_module(module_info, context)
          log_info(context) { <<-LOG }
            Загружен в память модуль бизнес-логики
            `#{module_info.logic_module}` версии `#{module_info.version}`
          LOG
        end

        # Ищет модуль среди констант пространства имён `Object` по
        # предоставленному названию модуля в змеином_регистре. При поиске из
        # названия модуля исключаются все символы `_`. Для ускорения работы
        # использует два списка, первый из которых интерпретируется как список
        # названий констант пространства имён `Object` до загрузки модуля из
        # внешнего файла, а второй список — список названий констант после
        # загрузки. Возвращает найденный модуль или `nil`, если невозможно
        # найти модуль.
        # @param [String] name
        #   название модуля в змеином_регистре
        # @return [Module]
        #   найденный модуль
        # @return [NilClass]
        #   если модуль невозможно найти
        def find_module(name)
          regexp = /\A#{name.tr('_', '')}\z/i
          module_name = Object.constants.find(&regexp.method(:match))
          module_name && Object.const_get(module_name)
        end

        # Вызывает функцию, если это возможно, у модуля бизнес-логики,
        # информация о котором предоставлена в качестве аргумента
        # @param [NilClass, CaseCore::Logic::Loader::ModuleInfo] module_info
        #   информация о модуле или `nil`
        # @param [Symbol] func_name
        #   название функции
        def call_logic_func(module_info, func_name)
          logic = module_info&.logic_module || return
          if logic.respond_to?(func_name)
            _result, e = safe_call(logic, func_name)
            log_func_call(e, logic, func_name, binding)
          else
            log_no_func(logic, func_name, binding)
          end
        end

        # Сообщение о том, что начинается перезагрузка всех модулей
        # бизнес-логики
        LOG_RELOAD_ALL_START =
          'Начинается перезагрузка всех модулей бизнес-логики'

        # Создаёт новую запись в журнале событий о том, что начинается полная
        # перезагрузка всех модулей бизнес-логики
        # @param [Binding] context
        #   контекст
        def log_reload_all_start(context)
          log_info(context) { LOG_RELOAD_ALL_START }
        end

        # Сообщение о том, что перезагрузка всех модулей бизнес-логики
        # завершена
        LOG_RELOAD_ALL_FINISH =
          'Перезагрузка всех модулей бизнес-логики завершена'

        # Создаёт новую запись в журнале событий о том, что полная перезагрузка
        # всех модулей бизнес-логики завершена
        # @param [Binding] context
        #   контекст
        def log_reload_all_finish(context)
          log_info(context) { LOG_RELOAD_ALL_FINISH }
        end
      end
    end
  end
end
