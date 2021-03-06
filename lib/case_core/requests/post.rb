# frozen_string_literal: true

require_relative 'base/request'

module CaseCore
  module Requests
    # Модуль, предоставляющий метод `post`, который осуществляет POST-запрос ко
    # внешнему ресурсу с помощью библиотеки `rest-client`
    module Post
      include Base::Request

      private

      # Выполняет POST-запрос
      # @param [Array<Hash>] args
      #   список ассоциативных массивов параметров запроса, все элементы
      #   которого объединяются в один ассоциативный массив. Параметр `:method`
      #   игнорируется.
      # @return [Object]
      #   полученный ответ
      def post(*args)
        execute_request(*args, method: :post)
      end
    end
  end
end
