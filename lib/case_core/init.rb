# frozen_string_literal: true

require 'set'
require 'singleton'

require_relative 'settings/configurable'

module CaseCore
  # Класс системы инициализации приложения. Позволяет указать директории с
  # файлами инициализации и загрузить только некоторые из них или все, кроме
  # некоторых. Предполагается, что файлы имеют формат `<no>_<name>.rb`, где
  # `<no>` — двухсимвольная строка, а `<name>` — строка с названием, которую
  # можно указать для инициализации. В обоих случаях файлы инициализации
  # загружаются согласно сортировке их полных имён (то есть с учётом префикса
  # `<no>_`).
  #
  # Пример. Пусть файлы инициализации располагаются в директории
  # `config/initializers`:
  #
  # ```
  # config/
  #   initializers/
  #     01_class_ext.rb
  #     02_sequel.rb
  #     03_rest.rb
  # ```
  #
  # Тогда в файле `config/app_init.rb` можно указать директорию с файлами
  # инициализации следующим образом:
  #
  # ```
  # CaseCore::Init.configure do |settings|
  #   settings.set :initializers, "#{__dir__}/initializers"
  # end
  # ```
  # После это можно загрузить инициализацию `sequel` следующим образом:
  #
  # ```
  # CaseCore::Init.run(only: %w[sequel])
  # ```
  # Аналогично загрузить всю инициализацию, кроме `sequel` можно с помощью
  # выполнения следующей команды:
  #
  # ```
  # CaseCore::Init.run(except: %w[sequel])
  # ```
  # При этом сначала загрузится файл `01_class_ext.rb`, а потом `03_rest.rb`.
  class Init
    extend  Settings::Configurable
    include Singleton

    settings_names :initializers

    # Инициализирует экземпляр класса
    def initialize
      @mutex = Thread::Mutex.new
    end

    # Запускает инициализацию приложения, если инициализация ещё не была
    # запущена
    # @param [Hash{:only, :except => Array}] params
    #   ассоциативный массив параметров инициализации
    def self.run!(params = {})
      instance.run!(params)
    end

    # Запускает инициализацию приложения, если инициализация ещё не была
    # запущена
    # @param [Hash{:only, :except => Array}] params
    #   ассоциативный массив параметров инициализации
    def run!(params)
      return if initialized?
      mutex.synchronize do
        return if initialized?
        initialized!
      end
      load_initializers(params)
    end

    private

    # Объект, с помощью которого происходит синхронизация учёта запуска
    # инициализации
    # @return [Thread::Mutex]
    #   объект, с помощью которого происходит синхронизация
    attr_reader :mutex

    # Возвращает, была ли запущена инициализация
    # @return [Boolean]
    #   была ли запущена инициализация
    def initialized?
      @initialized
    end

    # Отмечает, что инициализация запущена
    def initialized!
      @initialized = true
    end

    # Запускает инициализацию приложения
    # @param [Hash{:only, :except => Array}] params
    #   ассоциативный массив параметров инициализации
    def load_initializers(params)
      paths = Dir["#{Init.settings.initializers}/*.rb"]
      names = initializer_names(paths)
      only = Set.new(params[:only] || names.values)
      except = Set.new(params[:except])
      names.keep_if { |_, name| only.include?(name) && !except.include?(name) }
      names.keys.sort.each(&method(:require))
    end

    # Регулярное выражение, позволяющее извлечь название файла инициализации
    NAME_REGEXP = %r{\/.{2}_([^\/]*)\.rb$}

    # Возвращает ассоциативный массив, в котором полным путям файлов
    # инициализации сопоставляются их названия
    # @param [Array<String>] paths
    #   список полных путей файлов инициализации
    # @return [Hash]
    #   результирующий ассоциативный массив
    def initializer_names(paths)
      paths.each_with_object({}) do |path, memo|
        name = NAME_REGEXP.match(path)&.[](1)
        memo[path] = name unless name.nil?
      end
    end
  end
end
