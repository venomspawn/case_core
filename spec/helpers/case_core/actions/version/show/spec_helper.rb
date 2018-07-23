# frozen_string_literal: true

module CaseCore
  need 'actions/version/show/result_schema'

  module Actions
    module Version
      class Show
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
