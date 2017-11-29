# encoding: utf-8

module CaseCore
  module Actions
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Пространство имён для действий над записями заявок
    #
    module Cases
      require_relative 'cases/index'
      require_relative 'cases/show'

      # Возвращает список ассоциативных массивов атрибутов заявок
      #
      # @param [Hash] params
      #   ассоциативный массив параметров действия
      #
      # @return [Array<Hash>]
      #   список ассоциативных массивов атрибутов заявок
      #
      def self.index(params)
        Index.new(params).index
      end

      # Возвращает ассоциативный массив с информацией о заявке с
      # предоставленным идентификатором записи
      #
      # @param [Hash] params
      #   ассоциативный массив параметров действия
      #
      # @return [Hash]
      #   результирующий ассоциативный массив
      #
      def self.show(params)
        Show.new(params).show
      end
    end
  end
end
