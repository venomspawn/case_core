# frozen_string_literal: true

module CaseCore
  module Actions
    module Cases
      class Create
        # Модуль, предоставляющий пространства имён классов ошибок содержащему
        # классу
        module Errors
          # Пространство имён классов ошибок, связанных с модулями
          # бизнес-логики
          module Logic
            # Класс ошибок, сигнализирующих об отсутствии модуля бизнес-логики
            # для заявки заданного типа
            class NotFound < RuntimeError
              # Инициализирует объект класса
              # @param [CaseCore::Models::Case] c4s3
              #   запись заявки
              def initialize(c4s3)
                super(<<-MESSAGE.squish)
                  Не найден модуль бизнес-логики для заявки типа `#{c4s3.type}`
                MESSAGE
              end
            end
          end

          # Пространство имён классов ошибок, связанных с функциями
          # `on_case_creation` модулей бизнес-логики
          module OnCaseCreation
            # Класс ошибок, сигнализирующих об отсутствии функции
            # `on_case_creation` модуля бизнес-логики для заявки заданного типа
            class NotFound < RuntimeError
              # Инициализирует объект класса
              # @param [CaseCore::Models::Case] c4s3
              #   запись заявки
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
