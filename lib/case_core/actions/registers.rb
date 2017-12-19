# encoding: utf-8

module CaseCore
  module Actions
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Пространство имён для действий над записями реестров передаваемой
    # корреспонденции
    #
    module Registers
      require_relative 'registers/export'
      require_relative 'registers/index'
      require_relative 'registers/show'

      # Находит заявку в реестре передаваемой корреспонденции с данным
      # идентификатором записи и вызывает функцию `export_register` у модуля
      # бизнес-логики, обрабатывающей заявку, с записью реестра в качестве
      # аргумента
      #
      # @param [Hash] params
      #   ассоциативный массив параметров действия
      #
      # @raise [Sequel::NoMatchingRow]
      #   если невозможно найти запись реестра передаваемой корреспонденции
      #   по предоставленному в параметре `id` идентификатору
      #
      # @raise [RuntimeError]
      #   если в реестре передаваемой корреспонденции нет заявок
      #
      # @raise [RuntimeError]
      #   если невозможно найти модуль бизнес-логики по записи заявки
      #
      def self.export(params)
        Export.new(params).export
      end

      # Возвращает список ассоциативных массивов атрибутов реестров
      # передаваемой корреспонденции
      #
      # @param [Hash] params
      #   ассоциативный массив параметров действия
      #
      # @return [Array<Hash>]
      #   список ассоциативных массивов атрибутов реестров передаваемой
      #   корреспонденции
      #
      def self.index(params)
        Index.new(params).index
      end

      # Возвращает ассоциативный массив с информацией о реестре передаваемой
      # корреспонденции
      #
      # @param [Hash] params
      #   ассоциативный массив параметров действия
      #
      # @return [Hash]
      #   ассоциативный массив с информацией о реестре передаваемой
      #   корреспонденции
      #
      def self.show(params)
        Show.new(params).show
      end
    end
  end
end
