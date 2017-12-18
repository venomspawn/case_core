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
      require_relative 'requests/show'

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

      # Возвращает ассоциативный массив со всеми атрибутами межведомственного
      # запроса
      #
      # @param [Hash] params
      #   ассоциативный массив параметров действия
      #
      # @return [Hash]
      #   результирующий ассоциативный массив
      #
      # @raise [Sequel::NoMatchingRow]
      #   если запись заявки не найдена
      #
      def self.show(params)
        Show.new(params).show
      end
    end
  end
end
