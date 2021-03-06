# frozen_string_literal: true

module CaseCore
  module Logic
    class Loader
      # Модуль, предоставляющий родительскому классу пространства имён классов
      # ошибок
      module Errors
        # Пространство имён классов ошибок, связанных с модулями бизнес-логики
        module LogicModule
          # Класс ошибок, сообщающих, что модуль бизнес-логики не был найден
          # после загрузки внешнего файла
          class NotFound < RuntimeError
            # Инициализирует объект класса
            # @param [String] name
            #   название модуля в змеином_регистре
            # @param [String] filename
            #   путь до внешнего файла
            def initialize(name, filename)
              super(<<-MESSAGE.squish)
                Модуль `#{name}` не был найден после загрузки файла
                `#{filename}`
              MESSAGE
            end
          end

          # Класс ошибок, сообщающих, что модуль бизнес-логики не был найден
          # среди загруженных по предоставленному имени
          class NotFoundByName < RuntimeError
            # Инициализирует объект класса
            # @param [#to_s] name
            #   название модуля бизнес-логики
            def initialize(name)
              super("Модуль бизнес-логики не найден по названию `#{name}`")
            end
          end
        end
      end
    end
  end
end
