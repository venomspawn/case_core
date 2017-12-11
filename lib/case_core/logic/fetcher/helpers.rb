# encoding: utf-8

require "#{$lib}/helpers/log"

require_relative 'errors'

module CaseCore
  module Logic
    class Fetcher
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Вспомогательный модуль, предназначенный для включения в содержащий
      # класс
      #
      module Helpers
        include CaseCore::Helpers::Log

        # Создаёт новую запись в журнале событий о том, что начинается загрузка
        # и распаковка библиотеки с данными названием и версией
        #
        # @param [#to_s] name
        #   название библиотеки
        #
        # @param [String] version
        #   версия библиотеки
        #
        # @param [Binding] context
        #   context
        #
        def log_fetch_start(name, version, context)
          log_info(context) { version.empty? ? <<-LAST_VERSION : <<-VERSION }
            Начинается загрузка и распаковка библиотеки с названием `#{name}`
            последней версии
          LAST_VERSION
            Начинается загрузка и распаковка библиотеки с названием `#{name}`
            и версией `#{version}`
          VERSION
        end

        # Создаёт новую запись в журнале событий о том, что загрузка и
        # распаковка библиотеки с данными названием и версией успешно завершена
        #
        # @param [#to_s] name
        #   название библиотеки
        #
        # @param [#to_s] version
        #   версия библиотеки
        #
        # @param [Binding] context
        #   context
        #
        def log_fetch_finish(name, version, context)
          log_info(context) { <<-LOG }
            Загрузка и распаковка библиотеки с названием `#{name}` и версией
            `#{version}` успешно завершена
          LOG
        end

        # Создаёт новую запись в журнале событий о том, что во время загрузки
        # или распаковки библиотеки произошла ошибка
        #
        # @param [Exception] e
        #   объект с информацией об ошибке
        #
        # @param [Binding] context
        #   контекст
        #
        def log_fetch_error(e, context)
          log_error(context) { <<-LOG }
            Во время загрузки или распаковки библиотеки `#{name}` произошла
            ошибка `#{e.class}`: `#{e.message}`
          LOG
        end

        # Создаёт новую запись в журнале событий о том, что найдена последняя
        # версия библиотеки
        #
        # @param [#to_s] name
        #   название библиотеки
        #
        # @param [#to_s] last_version
        #   последняя версия библиотеки, найденная на сервере библиотек
        #
        # @param [Binding] context
        #   контекст
        #
        def log_last_version(name, last_version, context)
          log_info(context) { <<-LOG }
            Найдена версия `#{last_version}` библиотеки с названием `#{name}`
            на сервере библиотек
          LOG
        end

        # Создаёт новую запись в журнале событий о том, что распакован файл
        # библиотеки
        #
        # @param [String] entry_filepath
        #   путь к файлу
        #
        # @param [Binding] context
        #   контекст
        #
        def log_extract_entry(entry_filepath, context)
          log_debug(context) { "Распакован файл `#{entry_filepath}`" }
        end

        # Проверяет, что информация о последней версии библиотеки была найдена
        # на сервере библиотек
        #
        # @param [Object] version
        #   объект с информацией о последней версии библиотеки
        #
        # @raise [RuntimeError]
        #   если аргумент равен `nil`
        #
        def check_version!(version)
          raise Errors::Version::Nil.new(name) if version.nil?
        end

        # Проверяет, что тело файла с библиотекой было загружено с сервера
        # библиотек
        #
        # @param [Object] gem
        #   объект с информацией о теле файла с библиотекой
        #
        # @raise [RuntimeError]
        #   если аргумент равен `nil`
        #
        def check_gem!(gem)
          raise Errors::Gem::Nil.new(name, version) if gem.nil?
        end

        # Проверяет, что в файле с библиотекой найден архив, хранящий файлы
        # библиотеки
        #
        # @param [Object] entry
        #   объект с информацией об архиве
        #
        # @raise [RuntimeError]
        #   если аргумент равен `nil`
        #
        def check_packed_data_entry!(entry)
          raise Errors::PackedDataEntry::Nil.new(name, version) if entry.nil?
        end
      end
    end
  end
end
