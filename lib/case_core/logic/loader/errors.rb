# encoding: utf-8

module CaseCore
  module Logic
    class Loader
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Модуль, предоставляющий родительскому классу пространства имён классов
      # ошибок
      #
      module Errors
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Пространство имён классов ошибок, связанных с модулями бизнес-логики
        #
        module LogicModule
          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Класс ошибок, сообщающих, что модуль бизнес-логики не был найден
          # после загрузки внешнего файла
          #
          class NotFound < RuntimeError
            # Инициализирует объект класса
            #
            # @param [String] name
            #   название модуля в змеином_регистре
            #
            # @param [String] filename
            #   путь до внешнего файла
            #
            def initialize(name, filename)
              super(<<-MESSAGE.squish)
                Модуль `#{name}` не был найден после загрузки файла
                `#{filename}`
              MESSAGE
            end
          end
        end
      end
    end
  end
end
