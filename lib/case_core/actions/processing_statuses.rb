# encoding: utf-8

module CaseCore
  module Actions
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Пространство имён для действий над записями статусов обработки сообщений
    # STOMP
    #
    module ProcessingStatuses
      require_relative 'processing_statuses/show'

      # Возвращает ассоциативный массив с информацией о статусе обработки
      # сообщения STOMP
      #
      # @param [Hash] params
      #   ассоциативный массив параметров действия
      #
      # @return [Hash]
      #   ассоциативный массив с информацией о статусе обработки сообщения
      #   STOMP
      #
      def self.show(params)
        Show.new(params).show
      end
    end
  end
end
