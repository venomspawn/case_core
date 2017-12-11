# encoding: utf-8

require "#{$lib}/helpers/log"
require "#{$lib}/requests/get"
require "#{$lib}/requests/mixins/url"

module CaseCore
  module Logic
    class Fetcher
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Класс запросов к серверу библиотек, который предоставляет функцию
      # `latest_version`, возвращающую информацию о новейшей версии библиотеки
      # с заданным названием на сервере библиотек
      #
      class LatestVersionRequest
        include CaseCore::Helpers::Log
        include Requests::Get
        include Requests::Mixins::URL

        # Возвращает строку с информацией о новейшей версии библиотеки с
        # заданным названием, извлечённой из сервера библиотек, или `nil` в
        # случае, если библиотека отсутствует на сервере библиотек или во время
        # загрузки информации произошла ошибка
        #
        # @param [#to_s] name
        #   название библиотеки
        #
        # @return [String]
        #   строка с новейшей версией библиотеки на сервере библиотек
        #
        # @return [NilClass]
        #   если библиотека отсутствует на сервере библиотек или во время
        #   загрузки информации произошла ошибка
        #
        def self.latest_version(name)
          new(name).latest_version
        end

        # Инициализирует объект класса
        #
        # @param [#to_s] name
        #   название библиотеки
        #
        def initialize(name)
          @name = name.to_s
        end

        # Возвращает строку с информацией о новейшей версии библиотеки с
        # заданным названием, извлечённой из сервера библиотек, или `nil` в
        # случае, если библиотека отсутствует на сервере библиотек или во время
        # загрузки информации произошла ошибка
        #
        # @return [String]
        #   строка с новейшей версией библиотеки на сервере библиотек
        #
        # @return [NilClass]
        #   если библиотека отсутствует на сервере библиотек или во время
        #   загрузки информации произошла ошибка
        #
        def latest_version
          result = specs.reduce(nil) do |memo, spec|
            next memo unless spec.first == name
            version = spec[1]
            memo.nil? || memo < version ? version : memo
          end
          result.to_s if result.is_a?(Gem::Version)
        rescue => e
          log_latest_version_error(e, binding)
        end

        private

        # Строка с названием библиотеки
        #
        # @return [String]
        #   строка с названием библиотеки
        #
        attr_reader :name

        # Возвращает адрес сервера библиотек
        #
        # @return [#to_s]
        #   адрес сервера библиотек
        #
        def host
          Fetcher.settings.gem_server_host
        end

        # Возвращает порт сервера библиотек
        #
        # @return [#to_s]
        #   порт сервера библиотек
        #
        def port
          Fetcher.settings.gem_server_port
        end

        # Возвращает путь к файлу с информацией о всех библиотеках, хранящихся
        # на сервере библиотек
        #
        # @return [String]
        #   путь к файлу с информацией о всех библиотеках, хранящихся на
        #   сервере библиотек
        #
        def path
          "specs.#{Marshal::MAJOR_VERSION}.#{Marshal::MINOR_VERSION}"
        end

        # Возвращает структуру данных, извлечённую из файла с информацией о
        # всех библиотеках, хранящихся на сервере библиотек
        #
        # @return [Object]
        #   структура данных, извлечённую из файла с информацией о всех
        #   библиотеках, хранящихся на сервере библиотек
        #
        def specs
          specs_serialized = get.body
          Marshal.load(specs_serialized)
        end

        # Создаёт запись в журнале событий о том, что во время загрузки или
        # извлечения информации о последней версии библиотеки произошла ошибка
        #
        # @param [Exception] e
        #   объект с информацией об ошибке
        #
        # @param [Binding] context
        #   контекст
        #
        def log_latest_version_error(e, context)
          log_error(context) { <<-LOG }
            Во время загрузки или извлечения информации о последней версии
            библиотеки `#{name}` произошла ошибка `#{e.class}`: `#{e.message}`
          LOG
        end
      end
    end
  end
end
