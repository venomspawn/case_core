# frozen_string_literal: true

require 'singleton'

require_relative 'loader/helpers'
require_relative 'loader/module_info'
require_relative 'loader/scanner'
require_relative 'loader/settings'

module CaseCore
  need 'settings/configurable'

  # Пространство имён для классов, отвечающих за загрузку и поддержку
  # бизнес-логики из внешних библиотек
  module Logic
    # Класс, предоставляющий функцию `logic`, которая возвращает последнюю
    # версию модуля бизнес-логики, загружая его при необходимости из внешней
    # библиотеки
    class Loader
      extend  CaseCore::Settings::Configurable
      include Helpers
      include Singleton

      @settings_class = Settings

      # Возвращает последнюю версию модуля бизнес-логики, загружая его при
      # необходимости. Если при загрузке возникли ошибки, метод возвращает
      # `nil`.
      # @param [#to_s] name
      #   название модуля в змеином_регистре
      # @return [Module]
      #   модуль бизнес-логики
      # @return [NilClass]
      #   если при загрузке возникли ошибки
      def self.logic(name)
        instance.logic(name)
      end

      # Возвращает список загруженных модулей бизнес-логики
      # @return [Array<Module>]
      #   список загруженных модулей бизнес-логики
      def self.loaded_logics
        instance.loaded_logics
      end

      # Выгружает модуль бизнес-логики по предоставленному названию
      # @param [#to_s] logic
      #   название
      # @raise [RuntimeError]
      #   если модуль бизнес-логики не найден
      def self.unload(logic)
        instance.unload(logic)
      end

      # Выполняет действия по перезагрузке модулей бизнес-логики.
      #
      # 1.  Выгружает все загруженные модули бизнес-логики.
      # 2.  Заново сканирует директорию с библиотеками бизнес-логики и
      #     извлекает информацию о названиях и версиях библиотек.
      # 3.  Загружает все модули бизнес-логики.
      def self.reload_all
        instance.reload_all
      end

      # Инициализирует объект класса
      def initialize
        @mutex = Thread::Mutex.new
        @modules_info = {}
        @scanner = Scanner.new
      end

      # Возвращает последнюю версию модуля бизнес-логики, загружая его при
      # необходимости. Если при загрузке возникли ошибки, метод возвращает
      # `nil`.
      # @param [#to_s] name
      #   название модуля в змеином_регистре
      # @return [Module]
      #   модуль бизнес-логики
      # @return [NilClass]
      #   если при загрузке возникли ошибки
      def logic(name)
        name = name.to_s
        reload_module(name) if reload?(name)
        modules_info[name]&.logic_module
      end

      # Возвращает список загруженных модулей бизнес-логики
      # @return [Array<Module>]
      #   список загруженных модулей бизнес-логики
      def loaded_logics
        modules_info.values.map(&:logic_module)
      end

      # Выгружает модуль бизнес-логики по предоставленному названию
      # @param [#to_s] logic
      #   название
      # @return [Module]
      #   выгруженный модуль
      # @return [NilClass]
      #   если о модуле нет информации
      def unload(logic)
        name = logic.to_s.underscore
        mutex.synchronize { unload_module(name) }
      end

      # Выполняет действия по перезагрузке модулей бизнес-логики.
      #
      # 1.  Выгружает все загруженные модули бизнес-логики.
      # 2.  Заново сканирует директорию с библиотеками бизнес-логики и
      #     извлекает информацию о названиях и версиях библиотек.
      # 3.  Загружает все модули бизнес-логики.
      def reload_all
        scanner.reload_all
      end

      private

      # Объект, позволяющий синхронизировать добавление информации о модулях
      # бизнес-логики между различными потоками
      # @return [Thread::Mutex]
      #   объект, позволяющий синхронизировать добавление информации о модулях
      #   бизнес-логики между различными потоками
      attr_reader :mutex

      # Ассоциативный массив, который отображает названия модулей в
      # змеином_регистре в объекты с информацией об этих модулях
      # @return [Hash{String => CaseCore::Logic::Loader::ModuleInfo]
      #   ассоциативный массив, который отображает названия модулей в
      #   змеином_регистре в объекты с информацией об этих модулях
      attr_reader :modules_info

      # Объект, сканирующий директорию с библиотеками бизнес-логики
      # @return [CaseCore::Logic::Loader::Scanner]
      #   объект, сканирующий директорию с библиотеками бизнес-логики
      attr_reader :scanner

      # Возвращает путь к директории, в которой ищутся библиотеки с
      # бизнес-логикой, если этот путь был предварительно настроен в классе,
      # или `nil`, если путь не был настроен
      # @return [String]
      #   путь к директории
      # @return [NilClass]
      #   если путь к директории не был настроен в классе
      def dir
        Loader.settings.dir
      end

      # Возвращает, нужно ли перезагрузить модуль бизнес-логики
      # @param [String] name
      #   название модуля в змеином_регистре
      # @return [Boolean]
      #   нужно ли перезагрузить модуль бизнес-логики
      def reload?(name)
        !modules_info.key?(name) ||
          modules_info[name].version != scanner.libs[name]
      end

      # Возвращает модуль, сопоставленный предоставленному названию в
      # змеином_регистре, или `nil`, если предоставленному названию не
      # сопоставлен никакой модуль
      # @param [String] name
      #   название в змеином_регистре
      # @return [Module]
      #   модуль, сопоставленный предоставленному названию
      # @return [NilClass]
      #   если предоставленному названию не сопоставлен никакой модуль
      def extract_module(name)
        modules_info[name]&.logic_module
      end

      # Выгружает модуль бизнес-логики из памяти и загружает его из внешнего
      # файла, если это необходимо
      # @param [String] name
      #   название модуля в змеином_регистре
      def reload_module(name)
        mutex.synchronize do
          next unless reload?(name)
          unload_module(name)
          load_module(name)
        end
      end

      # Выгружает модуль из памяти, а также удаляет его из ассоциативного
      # массива {modules_info}
      # @param [String] name
      #   название модуля в змеином_регистре
      def unload_module(name)
        module_name = extract_module(name).to_s
        module_info = modules_info.delete(name)
        call_logic_func(module_info, :on_unload)
        return if module_name.empty? || !Object.const_defined?(module_name)
        Object.send(:remove_const, module_name).tap do
          log_unload_module(module_info, binding)
        end
      end

      # Возвращает полный путь к файлу с модулем для библиотеки бизнес-логики с
      # предоставленным названием
      # @param [String] name
      #   название библиотеки бизнес-логики
      # @return [String]
      #   результирующий путь
      def module_filename(name)
        version = last_module_version(name)
        "#{dir}/#{name}-#{version}/lib/#{name}.rb"
      end

      # Возвращает последнюю версию библиотеки бизнес-логики с предоставленным
      # названием
      # @param [String] name
      #   название библиотеки бизнес-логики
      # @return [String]
      #   последняя версия библиотеки бизнес-логики
      # @return [NilClass]
      #   если информация о библиотеки бизнес-логики с предоставленным
      #   названием отсутствует
      def last_module_version(name)
        scanner.libs[name]
      end

      # Загружает модуль из внешнего файла и возвращает его. Если во время
      # загрузки произошла ошибка, возвращает `nil`.
      # @param [String] name
      #   название модуля в змеином_регистре
      # @return [Module]
      #   загруженный модуль
      # @return [NilClass]
      #   если во время загрузки произошла ошибка
      def load_module(name)
        load_file(name).tap do |logic_module|
          module_info = insert_module_info(name, logic_module)
          log_load_module(module_info, binding)
          call_logic_func(module_info, :on_load)
        end
        # rubocop: disable Lint/RescueException
      rescue Exception => e
        # rubocop: enable Lint/RescueException
        log_load_module_error(name, e, binding)
      end

      # Загружает файл с модулем бизнес-логики, проверяет корректность
      # загрузки и возвращает загруженный модуль
      # @param [String] name
      #   название модуля в змеином_регистре
      # @return [Module]
      #   загруженный модуль
      # @raise [CaseCore::Logic::Loader::Errors::LogicModule::NotFound]
      #   если модуль не найден после загрузки
      def load_file(name)
        filename = module_filename(name)
        load filename
        find_module(name).tap do |logic_module|
          check_if_logic_module_is_found!(name, filename, logic_module)
        end
      end

      # Создаёт объект с информацией о модуле бизнес-логики, добавляет его в
      # ассоциативный массив {modules_info} и возвращает его
      # @param [String] name
      #   название модуля в змеином_регистре
      # @param [Module] logic_module
      #   модуль бизнес-логики
      # @return [CaseCore::Logic::Loader::ModuleInfo]
      #   результирующий объект
      def insert_module_info(name, logic_module)
        version = last_module_version(name)
        module_info = ModuleInfo.new(version, logic_module)
        modules_info[name] = module_info
      end
    end
  end
end
