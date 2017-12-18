# encoding: utf-8

module CaseCore
  module Actions
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Пространство имён для действий над записями межведомственных запросов,
    # созданных в рамках заявки
    #
    module Requests
      require_relative 'requests/create'
      require_relative 'requests/index'
      require_relative 'requests/show'
      require_relative 'requests/update'

      # Создаёт новую запись межведомственного запроса вместе с записями его
      # атрибутов и возвращает её
      #
      # @param [Hash] params
      #   ассоциативный массив параметров действия
      #
      # @return [CaseCore::Models::Request]
      #   созданная запись межведомственного запроса
      #
      def self.create(params)
        Create.new(params).create
      end

      # Возвращает список ассоциативных массивов атрибутов межведомственных
      # запросов, созданных в рамках заявки
      #
      # @param [Hash] params
      #   ассоциативный массив параметров действия
      #
      # @return [Array<Hash>]
      #   список ассоциативных массивов атрибутов межведомственных запросов,
      #   созданных в рамках заявки
      #
      def self.index(params)
        Index.new(params).index
      end

      # Возвращает ассоциативный массив со всеми атрибутами межведомственного
      # запроса
      #
      # @param [Hash] params
      #   ассоциативный массив параметров действия
      #
      # @return [Hash]
      #   результирующий ассоциативный массив
      #
      # @raise [Sequel::NoMatchingRow]
      #   если запись заявки не найдена
      #
      def self.show(params)
        Show.new(params).show
      end

      # Обновляет атрибуты межведомственного запроса с указанным
      # идентификатором записи
      #
      # @param [Hash] params
      #   ассоциативный массив параметров действия
      #
      # @raise [Sequel::ForeignKeyConstraintViolation]
      #   если запись межведомственного запроса не найдена по предоставленному
      #   идентификатору
      #
      def self.update(params)
        Update.new(params).update
      end
    end
  end
end
