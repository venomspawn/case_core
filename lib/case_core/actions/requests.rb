# frozen_string_literal: true

module CaseCore
  module Actions
    # Пространство имён для действий над записями межведомственных запросов,
    # созданных в рамках заявки
    module Requests
      require_relative 'requests/count'

      # Возвращает ассоциативный массив с информацией о количестве
      # межведомственных запросов, созданных в рамках заявки
      # @param [Object] params
      #   параметры действия
      # @param [NilClass, Hash] rest
      #   ассоциативный массив дополнительных параметров действия или `nil`,
      #   если дополнительные параметры отсутствуют
      # @return [Hash{count: Integer}]
      #   результирующий ассоциативный массив
      # @raise [Sequel::NoMatchingRow]
      #   если запись заявки не найдена
      def self.count(params, rest = nil)
        Count.new(params, rest).count
      end

      require_relative 'requests/create'

      # Создаёт новую запись межведомственного запроса вместе с записями его
      # атрибутов и возвращает её
      # @param [Object] params
      #   параметры действия
      # @param [NilClass, Hash] rest
      #   ассоциативный массив дополнительных параметров действия или `nil`,
      #   если дополнительные параметры отсутствуют
      # @return [CaseCore::Models::Request]
      #   созданная запись межведомственного запроса
      def self.create(params, rest = nil)
        Create.new(params, rest).create
      end

      require_relative 'requests/find'

      # Возвращает запись междведомственного запроса, найденную по
      # предоставленным атрибутам, или `nil`, если найти запись невозможно
      # @param [Object] params
      #   параметры действия
      # @param [NilClass, Hash] rest
      #   ассоциативный массив дополнительных параметров действия или `nil`,
      #   если дополнительные параметры отсутствуют
      # @return [CaseCore::Models::Request]
      #   найденная запись межведомственного запроса
      # @return [NilClass]
      #   если запись межведомственного запроса невозможно найти по
      #   предоставленным атрибутам
      def self.find(params, rest = nil)
        Find.new(params, rest).find
      end

      require_relative 'requests/index'

      # Возвращает список ассоциативных массивов атрибутов межведомственных
      # запросов, созданных в рамках заявки
      # @param [Object] params
      #   параметры действия
      # @param [NilClass, Hash] rest
      #   ассоциативный массив дополнительных параметров действия или `nil`,
      #   если дополнительные параметры отсутствуют
      # @return [Array<Hash>]
      #   список ассоциативных массивов атрибутов межведомственных запросов,
      #   созданных в рамках заявки
      def self.index(params, rest = nil)
        Index.new(params, rest).index
      end

      require_relative 'requests/show'

      # Возвращает ассоциативный массив со всеми атрибутами межведомственного
      # запроса
      # @param [Object] params
      #   параметры действия
      # @param [NilClass, Hash] rest
      #   ассоциативный массив дополнительных параметров действия или `nil`,
      #   если дополнительные параметры отсутствуют
      # @return [Hash]
      #   результирующий ассоциативный массив
      # @raise [Sequel::NoMatchingRow]
      #   если запись заявки не найдена
      def self.show(params, rest = nil)
        Show.new(params, rest).show
      end

      require_relative 'requests/update'

      # Обновляет атрибуты межведомственного запроса с указанным
      # идентификатором записи
      # @param [Object] params
      #   параметры действия
      # @param [NilClass, Hash] rest
      #   ассоциативный массив дополнительных параметров действия или `nil`,
      #   если дополнительные параметры отсутствуют
      # @raise [Sequel::ForeignKeyConstraintViolation]
      #   если запись межведомственного запроса не найдена по предоставленному
      #   идентификатору
      def self.update(params, rest = nil)
        Update.new(params, rest).update
      end
    end
  end
end
