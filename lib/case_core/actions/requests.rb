# frozen_string_literal: true

module CaseCore
  module Actions
    # Пространство имён для действий над записями межведомственных запросов,
    # созданных в рамках заявки
    module Requests
      require_relative 'requests/count'

      # Возвращает ассоциативный массив с информацией о количестве
      # межведомственных запросов, созданных в рамках заявки
      # @return [Hash{count: Integer}]
      #   результирующий ассоциативный массив
      # @raise [Sequel::NoMatchingRow]
      #   если запись заявки не найдена
      def self.count(params)
        Count.new(params).count
      end

      require_relative 'requests/create'

      # Создаёт новую запись межведомственного запроса вместе с записями его
      # атрибутов и возвращает её
      # @param [Hash] params
      #   ассоциативный массив параметров действия
      # @return [CaseCore::Models::Request]
      #   созданная запись межведомственного запроса
      def self.create(params)
        Create.new(params).create
      end

      require_relative 'requests/find'

      # Возвращает запись междведомственного запроса, найденную по
      # предоставленным атрибутам, или `nil`, если найти запись невозможно
      # @param [Hash] params
      #   ассоциативный массив параметров действия
      # @return [CaseCore::Models::Request]
      #   найденная запись межведомственного запроса
      # @return [NilClass]
      #   если запись межведомственного запроса невозможно найти по
      #   предоставленным атрибутам
      def self.find(params)
        Find.new(params).find
      end

      require_relative 'requests/index'

      # Возвращает список ассоциативных массивов атрибутов межведомственных
      # запросов, созданных в рамках заявки
      # @param [Hash] params
      #   ассоциативный массив параметров действия
      # @return [Array<Hash>]
      #   список ассоциативных массивов атрибутов межведомственных запросов,
      #   созданных в рамках заявки
      def self.index(params)
        Index.new(params).index
      end

      require_relative 'requests/show'

      # Возвращает ассоциативный массив со всеми атрибутами межведомственного
      # запроса
      # @param [Hash] params
      #   ассоциативный массив параметров действия
      # @return [Hash]
      #   результирующий ассоциативный массив
      # @raise [Sequel::NoMatchingRow]
      #   если запись заявки не найдена
      def self.show(params)
        Show.new(params).show
      end

      require_relative 'requests/update'

      # Обновляет атрибуты межведомственного запроса с указанным
      # идентификатором записи
      # @param [Hash] params
      #   ассоциативный массив параметров действия
      # @raise [Sequel::ForeignKeyConstraintViolation]
      #   если запись межведомственного запроса не найдена по предоставленному
      #   идентификатору
      def self.update(params)
        Update.new(params).update
      end
    end
  end
end
