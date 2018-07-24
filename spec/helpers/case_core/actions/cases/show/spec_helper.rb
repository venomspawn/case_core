# frozen_string_literal: true

module CaseCore
  need 'actions/cases/show/result_schema'

  module Actions
    module Cases
      class Show
        # Вспомогательный модуль, предназначенный для включения в тесты
        # содержащего класса
        module SpecHelper
          # Возвращает JSON-схему результата действия
          # @return [Object]
          #   JSON-схема результата действия
          def schema
            RESULT_SCHEMA
          end
        end
      end
    end
  end
end
