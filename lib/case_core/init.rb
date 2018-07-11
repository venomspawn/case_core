# frozen_string_literal: true

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

    settings_names :initializers, :root, :logger

    # Инициализирует экземпляр класса
    def initialize
      @mutex = Thread::Mutex.new
    end

    # Запускает инициализацию приложения, если инициализация ещё не была
    # запущена
    # @param [NilClass, Hash{:only, :except => Array}] params
    #   ассоциативный массив параметров инициализации или `nil`, если параметры
    #   инициализации отсутствуют
    def self.run!(params = nil)
      instance.run!(params)
    end

    # Запускает инициализацию приложения, если инициализация ещё не была
    # запущена
    # @param [NilClass, Hash{:only, :except => Array}] params
    #   ассоциативный массив параметров инициализации или `nil`, если параметры
    #   инициализации отсутствуют
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

    # Возвращает список полных путей к файлам инициализации
    # @return [Array<String>]
    #   список полных путей
    def paths
      Dir["#{Init.settings.initializers}/*.rb"]
    end

    # Регулярное выражение, позволяющее извлечь название файла инициализации
    NAME_REGEXP = %r{\/.{2}_([^\/]*)\.rb$}

    # Возвращает список полных путей к файлам инициализации
    # @param [Hash{:only, :except => Array}] params
    #   ассоциативный массив параметров инициализации
    # @return [Hash]
    #   результирующий ассоциативный массив
    def filtered_paths(params)
      only, except = params&.values_at(:only, :except)
      paths.each_with_object([]) do |path, memo|
        name = NAME_REGEXP.match(path)&.[](1)
        next if name.nil? || except&.include?(name)
        memo << path if only.nil? || only.include?(name)
      end
    end

    # Запускает инициализацию приложения
    # @param [Hash{:only, :except => Array}] params
    #   ассоциативный массив параметров инициализации
    def load_initializers(params)
      filtered_paths(params).sort.each(&method(:require))
    end
  end
end
