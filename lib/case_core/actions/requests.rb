# encoding: utf-8

module CaseCore
  module Actions
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Пространство имён для действий над записями межведомственных запросов,
    # созданных в рамках заявки
    #
    module Requests
      require_relative 'requests/index'

      # Возвращает список ассоциативных массивов атрибутов межведомственных
      # запросов, созданных в рамках заявки
      #
      # @param [Hash] params
      #   ассоциативный массив параметров действия
      #
      # @return [Array<Hash>]
      #   список ассоциативных массивов атрибутов межведомственных запросов,
      #   созданных в рамках заявки
      #
      def self.index(params)
        Index.new(params).index
      end
    end
  end
end
