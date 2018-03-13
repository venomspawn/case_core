# frozen_string_literal: true

require_relative 'wrappers/rest_client_wrapper'

module CaseCore
  module Requests
    # Пространство имён базовых модулей, предоставляющих методы, которые
    # осуществляют запросы ко внешним ресурсам
    module Base
      # Базовый модуль, предоставляющий метод `execute_request`, который
      # осуществляет запрос ко внешнему ресурсу. По умолчанию использует
      # библиотеку `rest-client` для осуществления запросов.
      module Request
        private

        # Выполняет REST-запрос
        # @param [Array<Hash>] *args
        #   список ассоциативных массивов параметров запроса, элементы которого
        #   объединяются в один ассоциативный массив с помощью вызова метода
        #   `deep_merge` (см. документацию по этому методу в библиотеке
        #   `active_support`)
        # @return [Object]
        #   полученный ответ
        def execute_request(*args)
          request_params = deep_merge_request_params(*args)
          request_wrapper.execute_request(request_params)
        end

        # Возвращает объект, предоставляющий метод `execute_request`, который
        # принимает единственный аргумент
        # @return [#execute_request]
        #   объект, предоставляющий метод `execute_request`, который принимает
        #   единственный аргумент
        def request_wrapper
          Wrappers::RestClientWrapper
        end

        # Составляет ассоциативный массив параметров запроса
        # @param [Array<Hash>] *args
        #   список ассоциативных массивов параметров запроса, элементы которого
        #   объединяются в один ассоциативный массив с помощью вызова метода
        #   `deep_merge` (см. документацию по этому методу в библиотеке
        #   `active_support`)
        # @return [Hash]
        #   результирующий ассоциативный массив
        def deep_merge_request_params(*args)
          {}.tap { |result| args.each(&result.method(:deep_merge!)) }
        end
      end
    end
  end
end
