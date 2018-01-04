# encoding: utf-8

module CaseCore
  module Logic
    class Loader
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Класс объектов, сканирующих директорию, в которой находятся
      # распакованные библиотеки с бизнес-логикой, и предоставляющих информацию
      # о версиях библиотек
      #
      class Scanner
        # Ассоциативный массив, в котором названиям библиотек в директории
        # библиотек сопоставлены их последние версии
        #
        attr_reader :libs

        # Инициализирует объект класса
        #
        def initialize
          @libs = {}
          @scanner = Thread.new(&method(:scan_periodically))
        end

        private

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
          Loader.settings.dir_check_period
        end

        # Возвращает путь к директории, в которой происходит сканирование
        #
        # @return [#to_s]
        #   путь к директории, в которой происходит сканирование
        #
        def dir
          Loader.settings.dir
        end

        # Запускает бесконечный цикл сканирования
        #
        def scan_periodically
          loop do
            scan
            sleep(dir_check_period)
          end
        end

        # Проверяет, изменилось ли содержимое сканируемой директории. Если
        # содержимое изменилось, перезагружает информацию о названиях библиотек
        # и их версиях
        #
        def scan
          dir_mtime = File.mtime(dir)
          return if last_mtime == dir_mtime
          @last_mtime = dir_mtime
          @libs = libs_info
          libs.keys.each(&Loader.method(:logic))
        end

        # Возвращает ассоциативный массив, в котором названиям библиотек
        # соответствуют строки с последними версиями этих библиотек
        #
        # @return [Hash{String => String}]
        #   ассоциативный массив, в котором названиям библиотек соответствуют
        #   строки с последними версиями этих библиотек
        #
        def libs_info
          range = (dir.size + 1)..-1
          all_names = Dir["#{dir}/*"].map { |gem_dir| gem_dir[range] }
          all_names.each_with_object({}, &method(:add_lib_info))
        end

        # Регулярное выражение, позволяющее извлечь название и версию
        # библиотеки из названия директории с библиотекой
        #
        # @example
        #   test_case-0.0.1 ~> test_case, 0.0.1
        #
        NAME_REGEXP = /^([a-z][a-z0-9_]*)-([0-9.]*)$/

        # Выставляет информацию о директории с библиотекой
        #
        # @param [String] dir_name
        #   название директории
        #
        # @param [Hash{String => String}] memo
        #   ассоциативный массив, в котором названиям библиотек соответствуют
        #   строки с последними версиями этих библиотек
        #
        def add_lib_info(dir_name, memo)
          match_data = NAME_REGEXP.match(dir_name)
          return if match_data.nil?
          lib_name = match_data[1]
          lib_version = match_data[2]
          memo[lib_name] = lib_version if memo[lib_name].to_s < lib_version
        end
      end
    end
  end
end
