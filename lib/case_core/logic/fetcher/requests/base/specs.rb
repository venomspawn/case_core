# frozen_string_literal: true

require_relative 'request'

module CaseCore
  module Logic
    class Fetcher
      module Requests
        module Base
          # Класс запросов к серверу библиотек, который предоставляет метод для
          # загрузки информации о всех библиотеках на сервере библиотек
          class Specs < Base::Request
            private

            # Версия библиотеки `marshal`
            MARSHAL_VERSION =
              "#{Marshal::MAJOR_VERSION}.#{Marshal::MINOR_VERSION}"

            # Путь к файлу с информацией о всех библиотеках, хранящихся на
            # сервере библиотек
            PATH = "latest_specs.#{MARSHAL_VERSION}.gz"

            # Возвращает путь к файлу с информацией о всех библиотеках,
            # хранящихся на сервере библиотек
            # @return [String]
            #   путь к файлу с информацией о всех библиотеках, хранящихся на
            #   сервере библиотек
            def path
              "#{super}/#{PATH}"
            end

            # Возвращает структуру данных, извлечённую из файла с информацией о
            # всех библиотеках, хранящихся на сервере библиотек
            # @return [Object]
            #   структура данных, извлечённую из файла с информацией о всех
            #   библиотеках, хранящихся на сервере библиотек
            def specs
              specs_serialized = Zlib.gunzip(get.body)
              # rubocop: disable Security/MarshalLoad
              Marshal.load(specs_serialized)
              # rubocop: enable Security/MarshalLoad
            end
          end
        end
      end
    end
  end
end
