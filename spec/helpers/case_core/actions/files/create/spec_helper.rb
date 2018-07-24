# frozen_string_literal: true

module CaseCore
  need 'actions/files/create/result_schema'

  module Actions
    module Files
      class Create
        # Вспомогательный модуль, предназначенный для включения в тесты
        # содержащего класса действия
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
