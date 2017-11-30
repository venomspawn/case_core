# encoding: utf-8

module CaseCore
  module Actions
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Пространство имён для действий над записями документов, прикреплённых к
    # заявке
    #
    module Documents
      require_relative 'documents/index'

      # Возвращает список ассоциативных массивов атрибутов документов,
      # прикреплённых к заявке
      #
      # @param [Hash] params
      #   ассоциативный массив параметров действия
      #
      # @return [Array<Hash>]
      #   список ассоциативных массивов атрибутов документов, прикреплённых к
      #   заявке
      #
      def self.index(params)
        Index.new(params).index
      end
    end
  end
end
