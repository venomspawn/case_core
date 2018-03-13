# frozen_string_literal: true

require_relative 'mixin'

module CaseCore
  module Settings
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Модуль, предоставляющий функцию создания класса настроек по списку
    # названий настроек
    #
    module ClassFactory
      # Возвращает новый класс настроек по списку названий настроек
      #
      # @param [Array<#to_s>] names
      #   список названий настроек
      #
      # @return [Class]
      #   класс настроек
      #
      def self.create(*names)
        names.map! { |name| name.is_a?(Symbol) ? name : name.to_s.to_sym }
        Struct.new(*names) { include Mixin }
      end
    end
  end
end
