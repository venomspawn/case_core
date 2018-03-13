# frozen_string_literal: true

require_relative 'class_factory'

module CaseCore
  module Settings
    # Модуль, предоставляющий методы возвращения настроек
    module Configurable
      # Возвращает настройки
      # @return [Settings]
      #   настройки
      def settings
        @settings ||= settings_class.new
      end

      # Конфигурирует настройки, общие для всех экземпляров сервиса
      # @yieldparam [Settings]
      #   настройки, общие для всех экземпляров сервиса
      def configure
        yield settings
      end

      private

      # Добавляет аргументы к списку названий настроек и возвращает его
      # @param [Array] args
      #   список новых названий настроек
      # @return [Array]
      #   список всех названий настроек
      def settings_names(*args)
        @settings_names ||= []
        @settings_names.concat(args)
      end

      # Возвращает класс настроек
      # @return [Class]
      #   класс настроек
      def settings_class
        @settings_class ||= ClassFactory.create(*settings_names)
      end
    end
  end
end
