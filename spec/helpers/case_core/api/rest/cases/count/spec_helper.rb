# frozen_string_literal: true

module CaseCore
  need 'actions/cases/count/result_schema'

  module API
    module REST
      module Cases
        module Count
          # Вспомогательный модуль, подключаемый к тестам REST API метода,
          # описанного в содержащем модуле
          module SpecHelper
            # Возвращает JSON-схему значения, возвращаемого REST API методом
            # @return [Hash]
            #   JSON-схема
            def schema
              Actions::Cases::Count::RESULT_SCHEMA
            end
          end
        end
      end
    end
  end
end
