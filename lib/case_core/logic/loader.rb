# encoding: utf-8

require 'singleton'

require "#{$lib}/settings/configurable"

require_relative 'loader/helpers'
require_relative 'loader/module_info'
require_relative 'loader/scanner'

module CaseCore
  # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
  #
  # Пространство имён для классов, отвечающих за загрузку и поддержку
  # бизнес-логики из внешних библиотек
  #
  module Logic
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Класс, предоставляющий функцию `logic`, которая возвращает последнюю
    # версию модуля бизнес-логики, загружая его при необходимости из внешней
    # библиотеки
    #
    class Loader
      include Helpers
      extend  Settings::Configurable
      include Singleton

      settings_names :dir, :dir_check_period

      # Возвращает последнюю версию модуля бизнес-логики, загружая его при
      # необходимости. Если при загрузке возникли ошибки, метод возвращает
      # `nil`.
      #
      # @param [#to_s] name
      #   название модуля в змеином_регистре
      #
      # @return [Module]
      #   модуль бизнес-логики
      #
      # @return [NilClass]
      #   если при загрузке возникли ошибки
      #
      def self.logic(name)
        instance.logic(name)
      end

      # Возвращает список загруженных модулей бизнес-логики
      #
      # @return [Array<Module>]
      #   список загруженных модулей бизнес-логики
      #
      def self.loaded_logics
        instance.loaded_logics
      end

      # Инициализирует объект класса
      #
      def initialize
        @mutex = Thread::Mutex.new
        @modules_info = {}
        @scanner = Scanner.new
      end

      # Возвращает последнюю версию модуля бизнес-логики, загружая его при
      # необходимости. Если при загрузке возникли ошибки, метод возвращает
      # `nil`.
      #
      # @param [#to_s] name
      #   название модуля в змеином_регистре
      #
      # @return [Module]
      #   модуль бизнес-логики
      #
      # @return [NilClass]
      #   если при загрузке возникли ошибки
      #
      def logic(name)
        name = name.to_s
        reload_module(name) if reload?(name)
        modules_info[name]&.logic_module
      end

      # Возвращает список загруженных модулей бизнес-логики
      #
      # @return [Array<Module>]
      #   список загруженных модулей бизнес-логики
      #
      def loaded_logics
        modules_info.values.map(&:logic_module)
      end

      private

      # Объект, позволяющий синхронизировать добавление информации о модулях
      # бизнес-логики между различными потоками
      #
      # @return [Thread::Mutex]
      #   объект, позволяющий синхронизировать добавление информации о модулях
      #   бизнес-логики между различными потоками
      #
      attr_reader :mutex

      # Ассоциативный массив, который отображает названия модулей в
      # змеином_регистре в объекты с информацией об этих модулях
      #
      # @return [Hash{String => CaseCore::Logic::Loader::ModuleInfo]
      #   ассоциативный массив, который отображает названия модулей в
      #   змеином_регистре в объекты с информацией об этих модулях
      #
      attr_reader :modules_info

      # Объект, сканирующий директорию с библиотеками бизнес-логики
      #
      # @return [CaseCore::Logic::Loader::Scanner]
      #   объект, сканирующий директорию с библиотеками бизнес-логики
      #
      attr_reader :scanner

      # Возвращает путь к директории, в которой ищутся библиотеки с
      # бизнес-логикой, если этот путь был предварительно настроен в классе,
      # или `nil`, если путь не был настроен
      #
      # @return [String]
      #   путь к директории
      #
      # @return [NilClass]
      #   если путь к директории не был настроен в классе
      #
      def dir
        Loader.settings.dir
      end

      # Возвращает, нужно ли перезагрузить модуль бизнес-логики
      #
      # @param [String] name
      #   название модуля в змеином_регистре
      #
      # @return [Boolean]
      #   нужно ли перезагрузить модуль бизнес-логики
      #
      def reload?(name)
        !modules_info.key?(name) ||
          modules_info[name].version != scanner.libs[name]
      end

      # Возвращает модуль, сопоставленный предоставленному названию в
      # змеином_регистре, или `nil`, если предоставленному названию не
      # сопоставлен никакой модуль
      #
      # @param [String] name
      #   название в змеином_регистре
      #
      # @return [Module]
      #   модуль, сопоставленный предоставленному названию
      #
      # @return [NilClass]
      #   если предоставленному названию не сопоставлен никакой модуль
      #
      def extract_module(name)
        modules_info[name]&.logic_module
      end

      # Выгружает модуль бизнес-логики из памяти и загружает его из внешнего
      # файла, если это необходимо
      #
      # @param [String] name
      #   название модуля в змеином_регистре
      #
      def reload_module(name)
        mutex.synchronize do
          next unless reload?(name)
          unload_module(name)
          load_module(name)
        end
      end

      # Выгружает модуль из памяти, а также удаляет его из ассоциативного
      # массива {modules_info}
      #
      # @param [String] name
      #   название модуля в змеином_регистре
      #
      def unload_module(name)
        module_name = extract_module(name).to_s
        module_info = modules_info.delete(name)
        call_logic_func(module_info, :on_unload)
        Object.send(:remove_const, module_name) unless module_name.empty?
      end

      # Ищет модуль среди констант пространства имён `Object` по
      # предоставленному названию модуля в змеином_регистре. При поиске из
      # названия модуля исключаются все символы `_`. Для ускорения работы
      # использует два списка, первый из которых интерпретируется как список
      # названий констант пространства имён `Object` до загрузки модуля из
      # внешнего файла, а второй список — список названий констант после
      # загрузки. Возвращает найденный модуль или `nil`, если невозможно найти
      # модуль.
      #
      # @param [String] name
      #   название модуля в змеином_регистре
      #
      # @param [Array] before
      #   список названий констант пространства имён `Object` _до_ загрузки
      #   модуля из внешнего файла
      #
      # @param [Array] after
      #   список названий констант пространства имён `Object` _после_ загрузки
      #   модуля из внешнего файла
      #
      # @return [Module]
      #   найденный модуль
      #
      # @return [NilClass]
      #   если модуль невозможно найти
      #
      def find_module(name, before, after)
        diff = after - before
        diff.map!(&:to_s)
        regexp = /^#{name.tr('_', '')}$/i
        module_name = diff.find { |const_name| regexp =~ const_name }
        Object.const_get(module_name) unless module_name.nil?
      end

      # Возвращает полный путь к файлу с модулем для библиотеки бизнес-логики с
      # предоставленным названием
      #
      # @param [String] name
      #   название библиотеки бизнес-логики
      #
      # @return [String]
      #   результирующий путь
      #
      def module_filename(name)
        version = last_module_version(name)
        "#{dir}/#{name}-#{version}/lib/#{name}.rb"
      end

      # Возвращает последнюю версию библиотеки бизнес-логики с предоставленным
      # названием
      #
      # @param [String] name
      #   название библиотеки бизнес-логики
      #
      # @return [String]
      #   последняя версия библиотеки бизнес-логики
      #
      # @return [NilClass]
      #   если информация о библиотеки бизнес-логики с предоставленным
      #   названием отсутствует
      #
      def last_module_version(name)
        scanner.libs[name]
      end

      # Загружает модуль из внешнего файла и возвращает его. Если во время
      # загрузки произошла ошибка, возвращает `nil`.
      #
      # @param [String] name
      #   название модуля в змеином_регистре
      #
      # @return [Module]
      #   загруженный модуль
      #
      # @return [NilClass]
      #   если во время загрузки произошла ошибка
      #
      def load_module(name)
        constants_before = Object.constants
        filename = module_filename(name)
        load filename
        logic_module = find_module(name, constants_before, Object.constants)
        check_if_logic_module_is_found!(name, filename, logic_module)
        version = last_module_version(name)
        module_info = ModuleInfo.new(version, logic_module)
        modules_info[name] = module_info
        call_logic_func(module_info, :on_load)
      rescue Exception => e
        log_load_module_error(name, e, binding)
      end

      # Вызывает функцию, если это возможно, у модуля бизнес-логики,
      # информация о котором предоставлена в качестве аргумента
      #
      # @param [NilClass, CaseCore::Logic::Loader::ModuleInfo]
      #   информация о модуле или `nil`
      #
      # @param [Symbol] func_name
      #   название функции
      #
      def call_logic_func(module_info, func_name)
        logic = module_info&.logic_module || return
        if logic.respond_to?(func_name)
          _result, e = safe_call(logic, func_name)
          log_func_error(e, logic, func_name, binding) unless e.nil?
        else
          log_no_func(logic, func_name, binding)
        end
      end
    end
  end
end
