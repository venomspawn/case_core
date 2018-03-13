# frozen_string_literal: true

require_relative 'base/request'

module CaseCore
  module Requests
    # Модуль, предоставляющий метод `get`, который осуществляет GET-запрос ко
    # внешнему ресурсу с помощью библиотеки `rest-client`
    module Get
      include Base::Request

      private

      # Выполняет GET-запрос
      # @param [Array<Hash>] *args
      #   список ассоциативных массивов параметров запроса, все элементы
      #   которого объединяются в один ассоциативный массив. Параметр `:method`
      #   игнорируется.
      # @return [Object]
      #   полученный ответ
      def get(*args)
        execute_request(*args, method: :get)
      end
    end
  end
end
