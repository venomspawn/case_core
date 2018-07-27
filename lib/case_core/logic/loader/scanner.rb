# frozen_string_literal: true

require 'rb-inotify'
require 'set'

module CaseCore
  module Logic
    class Loader
      # Класс объектов, сканирующих директорию, в которой находятся
      # распакованные библиотеки с бизнес-логикой, и предоставляющих информацию
      # о версиях библиотек
      class Scanner
        # Ассоциативный массив, в котором названиям библиотек в директории
        # библиотек сопоставлены их последние версии
        attr_reader :libs

        # Инициализирует объект класса
        def initialize
          @libs = {}
          @notifier = INotify::Notifier.new
          @watcher = create_watcher
          @scanner = Thread.new { notifier.run }
          reload_libs_info
        end

        # Выполняет действия по перезагрузке модулей бизнес-логике.
        #
        # 1.  Выгружает все загруженные модули бизнес-логики.
        # 2.  Заново сканирует директорию с библиотеками бизнес-логики и
        #     извлекает информацию о названиях и версиях библиотек.
        # 3.  Загружает все модули бизнес-логики.
        def reload_all
          Loader.loaded_logics.each(&Loader.method(:unload))
          reload_libs_info
          reload_watcher
          libs.each_key(&Loader.method(:logic))
        end

        private

        # Поток, в котором происходит сканирование
        # @return [Thread]
        #   поток в котором происходит сканирование
        attr_reader :scanner

        # Объект, оповещающий об изменениях в директории с библиотеками
        # бизнес-логики
        # @return [INotify::Notifier]
        #   объект, оповещающий об изменениях в директории с библиотеками
        #   бизнес-логики
        attr_reader :notifier

        # Объект, наблюдающий за изменениями в директории с библиотеками
        # бизнес-логики, или `nil`, если наблюдение не ведётся
        # @return [NilClass, INotify::Watcher]
        #   объект, наблюдающий за изменениями в директории с библиотеками
        #   бизнес-логики, или `nil`, если наблюдение не ведётся
        attr_reader :watcher

        # Возвращает путь к директории, в которой происходит сканирование
        # @return [String]
        #   путь к директории, в которой происходит сканирование
        def dir
          Loader.settings.dir.to_s
        end

        # Останавливает наблюдение за изменениями в директории с библиотеками
        # бизнес-логики
        def close_watcher
          watcher&.close
        ensure
          @watcher = nil
        end

        # Флаги, используемые при создании объекта, наблюдающего за изменениями
        # в директории с библиотеками бизнес-логики
        WATCHER_FLAGS = %i[
          create
          delete
          delete_self
          moved_from
          moved_to
          move_self
          onlydir
        ].freeze

        # Создаёт объект, наблюдающий за изменениями в директории с
        # библиотеками бизнес-логики, и возвращает его или `nil`, если во время
        # создания произошла ошибка
        # @return [INotify::Watcher]
        #   объект, наблюдающий за изменениями в директории с библиотеками
        #   бизнес-логики
        # @return [NilClass]
        #   если во время создания объекта произошла ошибка
        def create_watcher
          notifier.watch(dir, *WATCHER_FLAGS, &method(:process))
        rescue StandardError
          nil
        end

        # Создаёт заново объект, наблюдающий за изменениями в директории с
        # библиотеками бизнес-логики
        def reload_watcher
          close_watcher
          @watcher = create_watcher
        end

        # Ищет директории с библиотеками в директории {lib} по предоставленному
        # префиксу, добавляет информацию о библиотеках в предоставленный
        # ассоциативный массив и возвращает его
        # @param [#to_s] prefix
        #   префикс названий директорий
        # @param [Hash] memo
        #   ассоциативный массив с информацией о библиотеках
        # @return [Hash]
        #   заполненный ассоциативный массив
        def add_libs_info(prefix = nil, memo = {})
          pattern = "#{dir}/#{prefix}*"
          Dir[pattern].each_with_object(memo, &method(:add_lib_info))
        end

        # Обновляет ассоциативный массив {libs}, в котором названиям библиотек
        # соответствуют строки с последними версиями этих библиотек
        def reload_libs_info
          @libs = File.directory?(dir) ? add_libs_info : {}
        end

        # Регулярное выражение, позволяющее извлечь название и версию
        # библиотеки из названия директории с библиотекой
        # @example
        #   test_case-0.0.1 ~> test_case, 0.0.1
        NAME_REGEXP = /\A([a-z][a-z0-9_]*)-([0-9.]*)\z/

        # Возвращает список с названием и версией библиотеки, которая находится
        # в директории по предоставленному пути, или `nil`, если название или
        # версию библиотеки невозможно извлечь
        # @param [String] dir_path
        #   полный путь до директории
        # @return [Array<(String, String)>]
        #   список с названием и версией библиотеки
        # @return [NilClass]
        #   если название или версию библиотеки невозможно найти
        def extract_info(dir_path)
          dir_name = File.basename(dir_path)
          match_data = NAME_REGEXP.match(dir_name).to_a
          match_data[1..2]
        end

        # Выставляет информацию о директории с библиотекой
        # @param [String] dir_path
        #   полный путь до директории с библиотекой
        # @param [Hash{String => String}] memo
        #   ассоциативный массив, в котором названиям библиотек соответствуют
        #   строки с последними версиями этих библиотек
        def add_lib_info(dir_path, memo)
          lib_name, lib_version = extract_info(dir_path) || return
          memo[lib_name] = lib_version if memo[lib_name].to_s < lib_version
        end

        # Набор флагов, показывающих, что директория с библиотеками
        # бизнес-логики удалена или перемещена
        REMOVE_DIR_FLAGS = Set[:delete_self, :move_self]

        # Набор флагов, показывающих, что в директории с библиотеками
        # бизнес-логики появилась новая директория
        CREATE_SUBDIR_FLAGS = Set[:create, :moved_to]

        # Набор флагов, показывающих, что из директории с библиотеками
        # бизнес-логики исчезла директория
        REMOVE_SUBDIR_FLAGS = Set[:delete, :moved_from]

        # Задержка перед загрузкой библиотеки, необходимая после появления
        # директории. При копировании или распаковки директории сначала
        # создаётся сама директория, а потом её дочерние директории и файлы.
        # При попытке загрузить файл с модулем бизнес-логики сразу после
        # создания директории произойдёт ошибка, так как он ещё отсутствует.
        DELAY_DUE_CREATION = 0.1

        # Обрабатывает оповещение об изменениях в директории с библиотеками
        # бизнес-логики
        # @param [INotifier::Event] event
        #   объект с информацией об изменениях
        def process(event)
          flags = Set.new(event.flags)
          return reload_all if flags.intersect?(REMOVE_DIR_FLAGS)
          return unless flags.include?(:isdir)
          if flags.include?(:create)
            process_subdir_creation(event, DELAY_DUE_CREATION)
          elsif flags.include?(:moved_to)
            process_subdir_creation(event, 0)
          elsif flags.intersect?(REMOVE_SUBDIR_FLAGS)
            process_subdir_removal(event)
          end
        end

        # Обрабатывает оповещение о создании директории в директории с
        # библиотеками бизнес-логики или перемещении директории в директорию с
        # библиотеками бизнес-логики
        # @param [INotifier::Event] event
        #   объект с информацией об изменениях
        # @param [Numeric] delay
        #   задержка перед загрузкой бизнес-логики
        def process_subdir_creation(event, delay)
          lib_name, lib_version = extract_info(event.absolute_name) || return
          libs[lib_name] = lib_version if libs[lib_name].to_s < lib_version
          sleep(delay)
          Loader.logic(lib_name)
        end

        # Обрабатывает оповещение об удалении директории в директории с
        # библиотеками бизнес-логики или перемещении директории из директории с
        # библиотеками бизнес-логики
        # @param [INotifier::Event] event
        #   объект с информацией об изменениях
        def process_subdir_removal(event)
          lib_name, lib_version = extract_info(event.absolute_name) || return
          # Нет смысла обрабатывать, если удалена библиотека не текущей версии
          return unless libs[lib_name] == lib_version
          # Выгрузка модуля библиотеки
          Loader.unload(lib_name)
          libs.delete(lib_name) # nodoc
          # Поиск библиотек с таким же названием
          add_libs_info("#{lib_name}-", libs)
          # Загрузка модуля библиотеки в случае, если присутствует иная версия
          Loader.logic(lib_name) if libs.include?(lib_name)
        end
      end
    end
  end
end
