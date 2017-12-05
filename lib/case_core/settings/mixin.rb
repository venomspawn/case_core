# encoding: utf-8

module CaseCore
  # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
  #
  # Пространство имён для модулей, предоставляющих методы установки настроек
  #
  module Settings
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Модуль, предоставляющий методы установки настроек, предназначенный для
    # включения в классы настроек
    #
    module Mixin
      # Устанавливает значение настройки
      #
      # @param [#to_s] setting
      #   название настройки
      #
      # @param [Object] value
      #   значение настройки
      #
      def set(setting, value)
        send("#{setting}=", value)
      end

      # Устанавливает значение настройки равным `true`
      #
      # @param [#to_s] setting
      #   название настройки
      #
      def enable(setting)
        set(setting, true)
      end

      # Устанавливает значение настройки равным `false`
      #
      # @param [#to_s] setting
      #   название настройки
      #
      def disable(setting)
        set(setting, false)
      end
    end
  end
end
