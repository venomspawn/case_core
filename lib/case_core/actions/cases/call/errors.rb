# frozen_string_literal: true

module CaseCore
  module Actions
    module Cases
      class Call
        # Пространство имён модулей ошибок
        module Errors
          # Пространство имён модулей ошибок, связанных с модулем бизнес-логики
          module Logic
            # Класс ошибок, создаваемых, когда невозможно найти модуль
            # бизнес-логики для заявки данного типа
            class Absent < RuntimeError
              # Инициализирует объект класса
              # @param [CaseCore::Models::Case] c4s3
              #   запись заявки
              def initialize(c4s3)
                super(<<-MESSAGE.squish)
                  Невозможно найти модуль бизнес-логики для заявки типа
                  `#{c4s3.type}` с идентификатором записи `#{c4s3.id}`
                MESSAGE
              end
            end
          end
        end
      end
    end
  end
end
