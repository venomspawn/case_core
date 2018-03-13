# frozen_string_literal: true

module CaseCore
  module Logic
    class Loader
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Класс объектов, содержащих информацию о модуле бизнес-логики
      #
      class ModuleInfo
        # Время создания объекта
        #
        # @return [Time]
        #   время создания объекта
        #
        attr_reader :time

        # Версия библиотеки, содержащей модуль бизнес-логики
        #
        # @return [String]
        #   версия библиотеки, содержащей модуль бизнес-логики
        #
        attr_reader :version

        # Модуль бизнес-логики
        #
        # @return [Module]
        #   модуль бизнес-логики
        #
        attr_reader :logic_module

        # Инициализирует объект класса
        #
        # @param [String] version
        #   версия библиотеки, содержащей модуль бизнес-логики
        #
        # @param [Module] logic_module
        #   модуль бизнес-логики
        #
        def initialize(version, logic_module)
          @time         = Time.now
          @version      = version
          @logic_module = logic_module
        end
      end
    end
  end
end
