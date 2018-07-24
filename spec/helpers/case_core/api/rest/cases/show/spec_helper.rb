# frozen_string_literal: true

module CaseCore
  need 'actions/cases/show/result_schema'

  module API
    module REST
      module Cases
        module Show
          # Вспомогательный модуль, подключаемый к тестам REST API метода,
          # описанного в содержащем модуле
          module SpecHelper
            # Возвращает JSON-схему значения, возвращаемого REST API методом
            # @return [Hash]
            #   JSON-схема
            def schema
              Actions::Cases::Show::RESULT_SCHEMA
            end
          end
        end
      end
    end
  end
end
