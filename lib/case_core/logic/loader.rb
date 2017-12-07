# encoding: utf-8

require 'singleton'

require "#{$lib}/helpers/log"
require "#{$lib}/settings/configurable"

require_relative 'loader/errors'
require_relative 'loader/module_info'
require_relative 'loader/utils'

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
      include Helpers::Log
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

      # Инициализирует объект класса
      #
      def initialize
        @mutex = Thread::Mutex.new
        @modules_info = {}
        @dir_last_check = Time.now
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

      # Время последней проверки директории, в которой ищутся библиотеки с
      # бизнес-логикой
      #
      # @return [Time]
      #   время последней проверки директории, в которой ищутся библиотеки с
      #   бизнес-логикой
      #
      attr_reader :dir_last_check

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

      # Возвращает период в секундах между проверками на время изменения
      # директории, в которой ищутся библиотеки с бизнес-логикой
      #
      # @return [Numeric]
      #   период в секундах
      #
      def dir_check_period
        Loader.settings.dir_check_period
      end

      # Возвращает, допускается ли перезагрузка модуля с бизнес-логикой в
      # случае, если изменилось её содержимое
      #
      # @return [Boolean]
      #   допускается ли перезагрузка модуля с бизнес-логикой в случае, если
      #   изменилось её содержимое
      #
      def allow_to_reload?
        now = Time.now
        return false if dir_last_check > now
        @dir_last_check = now + dir_check_period
        true
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
        return true  unless modules_info.key?(name)
        return false unless allow_to_reload?
        utils = create_utils(name)
        utils.reload?
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

      # Создаёт вспомогательный объект, помогающий осуществлять проверки
      #
      # @param [String] name
      #   название модуля в змеином_регистре
      #
      # @return [CaseCore::Logic::Loader::Utils]
      #   вспомогательный объект, помогающий осуществлять проверки
      #
      def create_utils(name)
        Utils.new(dir, name, modules_info[name])
      end

      # Выгружает модуль бизнес-логики из памяти и загружает его из внешнего
      # файла, если это необходимо
      #
      # @param [String] name
      #   название модуля в змеином_регистре
      #
      def reload_module(name)
        mutex.synchronize do
          utils = create_utils(name)
          next if modules_info.key?(name) && !utils.reload?
          unload_module(name)
          load_module(name, utils)
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
        Object.send(:remove_const, module_name) unless module_name.empty?
        modules_info.delete(name)
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

      # Загружает модуль из внешнего файла и возвращает его. Если во время
      # загрузки произошла ошибка, возвращает `nil`.
      #
      # @param [String] name
      #   название модуля в змеином_регистре
      #
      # @param [CaseCore::Loader::Utils] utils
      #   вспомогательный объект, помогающий извлечь информацию о версии
      #   библиотеки с модулем и о пути к файлу с модулем
      #
      # @return [Module]
      #   загруженный модуль
      #
      # @return [NilClass]
      #   если во время загрузки произошла ошибка
      #
      def load_module(name, utils)
        constants_before = Object.constants
        load utils.filename
        logic_module = find_module(name, constants_before, Object.constants)
        check_if_logic_module_is_found!(name, utils.filename, logic_module)
        version = utils.last_lib_version
        modules_info[name] = ModuleInfo.new(version, logic_module)
      rescue Exception => e
        log_load_module_error(name, e, binding)
      end

      # Проверяет, что модуль был найден
      #
      # @param [String] name
      #   название модуля в змеином_регистре
      #
      # @param [String] filename
      #   путь к файлу с модулем
      #
      # @param [NilClass, Module] logic_module
      #   найденный модуль или `nil`, если модуль не был найден
      #
      # @raise [CaseCore::Logic::Loader::Errors::LogicModule::NotFound]
      #   если модуль не был найден
      #
      def check_if_logic_module_is_found!(name, filename, logic_module)
        return unless logic_module.nil?
        raise Errors::LogicModule::NotFound.new(name, filename)
      end

      # Создаёт запись в журнале событий о том, что во время загрузки модуля с
      # данным названием произошла ошибка
      #
      # @param [String] name
      #   название модуля в змеином_регистре
      #
      # @param [Exception] e
      #   объект с информацией об ошибке
      #
      # @param [Binding] context
      #   контекст
      #
      def log_load_module_error(name, e, context)
        log_error(context) { <<-LOG }
          Во время загрузки модуля с названием #{name} произошла ошибка
          `#{e.class}`: `#{e.message}`
        LOG
      end
    end
  end
end
