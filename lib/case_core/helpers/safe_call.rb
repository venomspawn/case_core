# encoding: utf-8

module CaseCore
  module Helpers
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Модуль для включения поддержки безопасных вызовов методов объектов
    #
    module SafeCall
      # Вызывает метод с данными именем и аргументами у предоставленного
      # объекта
      #
      # @param [Object] obj
      #   объект, чей метод будет вызван
      #
      # @param [#to_s] name
      #   название метода
      #
      # @param [Array] args
      #   список аргументов метода
      #
      # @return [Array<(Object, Object)>]
      #   список из двух элементов. Если во время вызова метода не возникло
      #   никаких исключений, то первый элемент равен значению, возвращённым
      #   вызываемым методом, а второй равен `nil`. Если исключение возникло,
      #   то первый элемент равен `nil`, а второй является объектом класса
      #   `Exception` с информацией об исключении.
      #
      def safe_call(obj, name, *args)
        name = name.to_s
        result = obj.send(name, *args)
        [result, nil]
      rescue Exception => e
        [nil, e]
      end
    end
  end
end
