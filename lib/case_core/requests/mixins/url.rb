# frozen_string_literal: true

module CaseCore
  module Requests
    # Пространство имён для модулей, подключаемых к классам, к которым уже
    # подключен модуль {CaseCore::Requests::Base::Request}
    module Mixins
      # Модуль, предназначенный для подключения к классам, к которым уже
      # подключён модуль {CaseCore::Requests::Base::Request}. Модуль
      # предоставляет поддержку формирования URL при запросе.
      module URL
        private

        # Выполняет REST-запрос, подставляя сформированный URL
        # @param [Array<Hash>] args
        #   список ассоциативных массивов параметров запроса, элементы которого
        #   объединяются в один ассоциативный массив с помощью вызова метода
        #   `deep_merge` (см. документацию по этому методу в библиотеке
        #   `active_support`)
        # @return [Object]
        #   полученный ответ
        def execute_request(*args)
          super(*args, url: url)
        end

        # Возвращает строку со сформированным URL
        # @return [String]
        #   строка со сформированным URL
        def url
          "#{host}:#{port}/#{path}"
        end

        # Возвращает адрес сервера, на который происходит REST-запрос
        # @return [#to_s]
        #   адрес сервера
        def host
          raise "Метод `#{__method__}` не реализован"
        end

        # Возвращает порт сервера, на который происходит REST-запрос
        # @return [#to_s]
        #   порт сервера
        def port
          raise "Метод `#{__method__}` не реализован"
        end

        # Возвращает путь до REST-метода, подставляемый в URL
        # @return [#to_s]
        #   путь
        def path
          raise "Метод `#{__method__}` не реализован"
        end
      end
    end
  end
end
