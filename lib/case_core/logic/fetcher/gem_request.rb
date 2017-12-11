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
      # `gem`, возвращающую тело файла с библиотекой с данными названием и
      # версией на сервере библиотек
      #
      class GemRequest
        include CaseCore::Helpers::Log
        include Requests::Get
        include Requests::Mixins::URL

        # Возвращает тело файла с библиотекой с данными названием и версией на
        # сервере библиотек или `nil`, если во время загрузки файла произошла
        # ошибка
        #
        # @param [#to_s] name
        #   название библиотеки
        #
        # @param [#to_s] version
        #   версия библиотеки
        #
        # @return [String]
        #   тело файла с библиотекой
        #
        # @return [NilClass]
        #   если во время загрузки файла произошла ошибка
        #
        def self.gem(name, version)
          new(name, version).gem
        end

        # Инициализация объекта класса
        #
        # @param [#to_s] name
        #   название библиотеки
        #
        # @param [#to_s] version
        #   версия библиотеки
        #
        def initialize(name, version)
          @name = name
          @version = version
        end

        # Возвращает тело файла с библиотекой с данными названием и версией на
        # сервере библиотек или `nil`, если во время загрузки файла произошла
        # ошибка
        #
        # @return [String]
        #   тело файла с библиотекой
        #
        # @return [NilClass]
        #   если во время загрузки файла произошла ошибка
        #
        def gem
          get.body
        rescue => e
          log_gem_error(e, binding)
        end

        private

        # Название библиотеки
        #
        # @return [#to_s]
        #   название библиотеки
        #
        attr_reader :name

        # Версия библиотеки
        #
        # @return [#to_s]
        #   версия библиотеки
        #
        attr_reader :version

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
          "gems/#{name}-#{version}.gem"
        end

        # Создаёт запись в журнале событий о том, что во время загрузки файла
        # библиотеки произошла ошибка
        #
        # @param [Exception] e
        #   объект с информацией об ошибке
        #
        # @param [Binding] context
        #   контекст
        #
        def log_gem_error(e, context)
          log_error(context) { <<-LOG }
            Во время загрузки файла библиотеки `#{name}` версии `#{version}`
            произошла ошибка `#{e.class}`: `#{e.message}`
          LOG
        end
      end
    end
  end
end
