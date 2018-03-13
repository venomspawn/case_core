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
      # @param [Hash] params
      #   ассоциативный массив параметров действия
      def self.create(params)
        Create.new(params).create
      end

      # Возвращает список ассоциативных массивов атрибутов документов,
      # прикреплённых к заявке
      # @param [Hash] params
      #   ассоциативный массив параметров действия
      # @return [Array<Hash>]
      #   список ассоциативных массивов атрибутов документов, прикреплённых к
      #   заявке
      def self.index(params)
        Index.new(params).index
      end

      # Обновляет запись документа
      # @param [Hash] params
      #   ассоциативный массив параметров действия
      def self.update(params)
        Update.new(params).update
      end
    end
  end
end
