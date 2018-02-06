# encoding: utf-8

module CaseCore
  module Actions
    module Cases
      class Create
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Модуль, предоставляющий пространства имён классов ошибок содержащему
        # классу
        #
        module Errors
          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Пространство имён классов ошибок, связанных с модулями
          # бизнес-логики
          #
          module Logic
            # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
            #
            # Класс ошибок, сигнализирующих об отсутствии модуля бизнес-логики
            # для заявки заданного типа
            #
            class NotFound < RuntimeError
              # Инициализирует объект класса
              #
              # @param [CaseCore::Models::Case] c4s3
              #   запись заявки
              #
              def initialize(c4s3)
                super(<<-MESSAGE.squish)
                  Не найден модуль бизнес-логики для заявки типа `#{c4s3.type}`
                MESSAGE
              end
            end
          end

          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Пространство имён классов ошибок, связанных с функциями
          # `on_case_creation` модулей бизнес-логики
          #
          module OnCaseCreation
            # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
            #
            # Класс ошибок, сигнализирующих об отсутствии функции
            # `on_case_creation` модуля бизнес-логики для заявки заданного типа
            #
            class NotFound < RuntimeError
              # Инициализирует объект класса
              #
              # @param [CaseCore::Models::Case] c4s3
              #   запись заявки
              #
              def initialize(c4s3)
                super(<<-MESSAGE.squish)
                  Не найдена функция `on_case_creation` модуля бизнес-логики
                  для заявки типа `#{c4s3.type}`
                MESSAGE
              end
            end
          end
        end
      end
    end
  end
end
