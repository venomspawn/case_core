# encoding: utf-8

module CaseCore
  module Actions
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Пространство имён для действий над записями реестров передаваемой
    # корреспонденции
    #
    module Registers
      require_relative 'registers/index'
      require_relative 'registers/show'

      # Возвращает список ассоциативных массивов атрибутов реестров
      # передаваемой корреспонденции
      #
      # @param [Hash] params
      #   ассоциативный массив параметров действия
      #
      # @return [Array<Hash>]
      #   список ассоциативных массивов атрибутов реестров передаваемой
      #   корреспонденции
      #
      def self.index(params)
        Index.new(params).index
      end

      # Возвращает ассоциативный массив с информацией о реестре передаваемой
      # корреспонденции
      #
      # @param [Hash] params
      #   ассоциативный массив параметров действия
      #
      # @return [Hash]
      #   ассоциативный массив с информацией о реестре передаваемой
      #   корреспонденции
      #
      def self.show(params)
        Show.new(params).show
      end
    end
  end
end
