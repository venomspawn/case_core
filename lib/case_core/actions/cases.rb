# encoding: utf-8

module CaseCore
  module Actions
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Пространство имён для действий над записями заявок
    #
    module Cases
      require_relative 'cases/index'

      # Возвращает список ассоциативных массивов атрибутов заявок
      #
      # @param [Hash]
      #   ассоциативный массив параметров действия
      #
      # @return [Array<Hash>]
      #   список ассоциативных массивов атрибутов заявок
      #
      def self.index(params)
        Index.new(params).index
      end
    end
  end
end
