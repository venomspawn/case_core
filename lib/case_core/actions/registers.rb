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
    end
  end
end
