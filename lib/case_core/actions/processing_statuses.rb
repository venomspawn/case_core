# frozen_string_literal: true

module CaseCore
  module Actions
    # Пространство имён для действий над записями статусов обработки сообщений
    # STOMP
    module ProcessingStatuses
      require_relative 'processing_statuses/show'

      # Возвращает ассоциативный массив с информацией о статусе обработки
      # сообщения STOMP
      # @param [Object] params
      #   параметры действия
      # @param [NilClass, Hash] rest
      #   ассоциативный массив дополнительных параметров действия или `nil`,
      #   если дополнительные параметры отсутствуют
      # @return [Hash]
      #   ассоциативный массив с информацией о статусе обработки сообщения
      #   STOMP
      def self.show(params, rest = nil)
        Show.new(params, rest).show
      end
    end
  end
end
