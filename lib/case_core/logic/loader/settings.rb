# frozen_string_literal: true

module CaseCore
  need 'settings/mixin'

  module Logic
    class Loader
      # Класс настроек содержащего класса
      class Settings
        include CaseCore::Settings::Mixin

        # Полный путь до директории с библиотеками бизнес-логики
        # @return [#to_s]
        #   полный путь до директории с библиотеками бизнес-логики
        attr_reader :dir

        # Устанавливает полный путь до директории с библиотеками бизнес-логики
        # @param [#to_s] value
        #   полный путь до директории с библиотеками бизнес-логики
        # @return [#to_s]
        #   аргумент
        def dir=(value)
          @dir = value
          Loader.reload_all
        end
      end
    end
  end
end
