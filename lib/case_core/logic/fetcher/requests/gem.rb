# frozen_string_literal: true

require_relative 'base/request'

module CaseCore
  need 'helpers/log'

  module Logic
    class Fetcher
      module Requests
        # Класс запросов к серверу библиотек, который предоставляет функцию
        # `gem`, возвращающую тело файла с библиотекой с данными названием и
        # версией на сервере библиотек
        class Gem < Base::Request
          include CaseCore::Helpers::Log

          # Возвращает тело файла с библиотекой с данными названием и версией
          # на сервере библиотек или `nil`, если во время загрузки файла
          # произошла ошибка
          # @param [#to_s] name
          #   название библиотеки
          # @param [#to_s] version
          #   версия библиотеки
          # @return [String]
          #   тело файла с библиотекой
          # @return [NilClass]
          #   если во время загрузки файла произошла ошибка
          def self.gem(name, version)
            new(name, version).gem
          end

          # Инициализация объекта класса
          # @param [#to_s] name
          #   название библиотеки
          # @param [#to_s] version
          #   версия библиотеки
          def initialize(name, version)
            @name = name
            @version = version
          end

          # Возвращает тело файла с библиотекой с данными названием и версией
          # на сервере библиотек или `nil`, если во время загрузки файла
          # произошла ошибка
          # @return [String]
          #   тело файла с библиотекой
          # @return [NilClass]
          #   если во время загрузки файла произошла ошибка
          def gem
            get.body
          rescue StandardError => err
            log_gem_error(err, binding)
          end

          private

          # Название библиотеки
          # @return [#to_s]
          #   название библиотеки
          attr_reader :name

          # Версия библиотеки
          # @return [#to_s]
          #   версия библиотеки
          attr_reader :version

          # Возвращает путь к файлу с информацией о всех библиотеках,
          # хранящихся на сервере библиотек
          # @return [String]
          #   путь к файлу с информацией о всех библиотеках, хранящихся на
          #   сервере библиотек
          def path
            "#{super}/gems/#{name}-#{version}.gem"
          end

          # Создаёт запись в журнале событий о том, что во время загрузки файла
          # библиотеки произошла ошибка
          # @param [Exception] err
          #   объект с информацией об ошибке
          # @param [Binding] context
          #   контекст
          def log_gem_error(err, context)
            log_error(context) { <<-LOG }
              Во время загрузки файла библиотеки `#{name}` версии `#{version}`
              произошла ошибка `#{err.class}`: `#{err.message}`
            LOG
          end
        end
      end
    end
  end
end
