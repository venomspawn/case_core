# frozen_string_literal: true

module CaseCore
  module Actions
    # Пространство имён классов действий, возвращающих информацию о версии
    # приложения и модулей бизнес-логики
    module Version
      require_relative 'version/show'

      # Возвращает ассоциативный массив с информацией о версии приложения и
      # модулей бизнес-логики
      # @param [Hash] params
      #   ассоциативный массив параметров действия
      # @return [Hash]
      #   результирующий ассоциативный массив
      def self.show(params)
        Show.new(params).show
      end
    end
  end
end
