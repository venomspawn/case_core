# frozen_string_literal: true

module CaseCore
  module Actions
    # Пространство имён классов действий, возвращающих информацию о версии
    # приложения и модулей бизнес-логики
    module Version
      require_relative 'version/show'

      # Возвращает ассоциативный массив с информацией о версии приложения и
      # модулей бизнес-логики
      # @param [Object] params
      #   параметры действия
      # @param [NilClass, Hash] rest
      #   ассоциативный массив дополнительных параметров действия или `nil`,
      #   если дополнительные параметры отсутствуют
      # @return [Hash]
      #   результирующий ассоциативный массив
      def self.show(params, rest = nil)
        Show.new(params, rest).show
      end
    end
  end
end
