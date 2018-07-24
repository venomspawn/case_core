# frozen_string_literal: true

module CaseCore
  module Actions
    # Пространство имён для действий над записями документов, прикреплённых к
    # заявке
    module Documents
      require_relative 'documents/create'
      require_relative 'documents/index'
      require_relative 'documents/update'

      # Создаёт запись документа и прикрепляет её к записи заявки
      # @param [Object] params
      #   параметры действия
      # @param [NilClass, Hash] rest
      #   ассоциативный массив дополнительных параметров действия или `nil`,
      #   если дополнительные параметры отсутствуют
      def self.create(params, rest = nil)
        Create.new(params, rest).create
      end

      # Возвращает список ассоциативных массивов атрибутов документов,
      # прикреплённых к заявке
      # @param [Object] params
      #   параметры действия
      # @param [NilClass, Hash] rest
      #   ассоциативный массив дополнительных параметров действия или `nil`,
      #   если дополнительные параметры отсутствуют
      # @return [Array<Hash>]
      #   список ассоциативных массивов атрибутов документов, прикреплённых к
      #   заявке
      def self.index(params, rest = nil)
        Index.new(params, rest).index
      end

      # Обновляет запись документа
      # @param [Object] params
      #   параметры действия
      # @param [NilClass, Hash] rest
      #   ассоциативный массив дополнительных параметров действия или `nil`,
      #   если дополнительные параметры отсутствуют
      def self.update(params, rest = nil)
        Update.new(params, rest).update
      end
    end
  end
end
