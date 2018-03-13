# frozen_string_literal: true

module CaseCore
  module Helpers
    # Модуль для включения поддержки безопасных вызовов методов объектов
    module SafeCall
      private

      # Вызывает метод с данными именем и аргументами у предоставленного
      # объекта
      # @param [Object] obj
      #   объект, чей метод будет вызван
      # @param [#to_s] name
      #   название метода
      # @param [Array] args
      #   список аргументов метода
      # @return [Array<(Object, Object)>]
      #   список из двух элементов. Если во время вызова метода не возникло
      #   никаких исключений, то первый элемент равен значению, возвращённым
      #   вызываемым методом, а второй равен `nil`. Если исключение возникло,
      #   то первый элемент равен `nil`, а второй является объектом класса
      #   `Exception` с информацией об исключении.
      def safe_call(obj, name, *args)
        name = name.to_s
        result = obj.send(name, *args)
        [result, nil]
        # rubocop: disable Lint/RescueException
      rescue Exception => err
        # rubocop: enable Lint/RescueException
        [nil, err]
      end
    end
  end
end
