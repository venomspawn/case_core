# frozen_string_literal: true

module CaseCore
  module Actions
    module Files
      class Show < Base::Action
        # Модуль пространств имён классов ошибок
        module Errors
          # Пространство имён классов ошибок, связанных с записями файлов
          module File
            # Класс ошибок, сигнализирующих о том, что запись файла не найдена
            class NotFound < Sequel::NoMatchingRow
              # Инициализирует объект класса
              # @param [#to_s] id
              #   идентификатор записи файла
              def initialize(id)
                super("Запись файла с идентификатором `#{id}` не найдена")
              end
            end
          end
        end
      end
    end
  end
end
