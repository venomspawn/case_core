# encoding: utf-8

require 'singleton'

require "#{$lib}/settings/configurable"

module CaseCore
  module Logic
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Класс объектов, сканирующих директорию, в которой находятся распакованные
    # библиотеки с бизнес-логикой, и загружающих новые модули бизнес-логики
    #
    class Scanner
      extend  Settings::Configurable
      include Singleton

      settings_names :dir_check_period

      # Запускает сканер
      #
      def self.run!
        instance.run!
      end

      # Останавливает сканер
      #
      def self.stop!
        instance.stop!
      end

      # Возвращает, запущен ли сканет
      #
      # @return [Boolean]
      #   запущен ли сканер
      #
      def self.running?
        instance.running?
      end

      # Инициализирует объект класса
      #
      def initialize
        @mutex = Thread::Mutex.new
      end

      # Запускает сканер
      #
      def run!
        return if running?
        mutex.synchronize do
          @scanner = Thread.new(&method(:scan_periodically)) unless running?
        end
      end

      # Останавливает сканер
      #
      def stop!
        return unless running?
        mutex.synchronize do
          return unless running?
          scanner.kill
          @scanner = nil
        end
      end

      # Возвращает, запущен ли сканет
      #
      # @return [Boolean]
      #   запущен ли сканер
      #
      def running?
        !scanner.nil?
      end

      private

      # Объект, с помощью которого синхронизируется запуск сканера
      #
      # @return [Thread::Mutex]
      #   объект, с помощью которого синхронизируется запуск сканера
      #
      attr_reader :mutex

      # Поток, в котором происходит сканирование
      #
      # @return [Thread]
      #   поток в котором происходит сканирование
      #
      attr_reader :scanner

      # Время обновления директории, в которой происходит сканирование
      #
      # @return [Time]
      #   время обновления директории, в которой происходит сканирование
      #
      attr_reader :last_mtime

      # Возвращает периодичность повторения сканирования в секундах
      #
      # @return [Numeric]
      #   периодичность повторения сканирования в секундах
      #
      def dir_check_period
        Scanner.settings.dir_check_period
      end

      # Возвращает путь к директории, в которой происходит сканирование
      #
      # @return [#to_s]
      #   путь к директории, в которой происходит сканирование
      #
      def dir
        Loader.settings.dir
      end

      # Запускает бесконечный цикл сканирования с установленной периодичностью
      #
      def scan_periodically
        loop do
          sleep(dir_check_period)
          scan
        end
      end

      # Проверяет, изменилось ли содержимое сканируемой директории. Если
      # содержимое изменилось, загружает все модули бизнес-логики, находящиеся
      # в библиотеках в сканируемой директории.
      #
      def scan
        dir_mtime = File.mtime(dir)
        return if last_mtime == dir_mtime
        @last_mtime = dir_mtime
        names.each(&Loader.method(:logic))
      end

      # Регулярное выражение, позволяющее извлечь название библиотеки
      #
      # @example
      #   test_case-0.0.1 ~> test_case
      #
      NAME_REGEXP = /^([a-z][a-z0-9_]*)-[0-9.]*$/

      # Возвращает список названий библиотек, находящихся в сканируемой
      # директории
      #
      # @return [Array<String>]
      #   список названий библиотек
      #
      def names
        gems_dir = dir
        range = (gems_dir.size + 1)..-1
        all_names = Dir["#{gems_dir}/*"].map { |gem_dir| gem_dir[range] }
        match_names = all_names.map do |name|
          match_data = NAME_REGEXP.match(name)
          match_data && match_data[1]
        end
        match_names.compact.uniq
      end
    end
  end
end
