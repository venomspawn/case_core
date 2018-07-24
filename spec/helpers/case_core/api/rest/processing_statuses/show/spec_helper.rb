# frozen_string_literal: true

module CaseCore
  need 'actions/processing_statuses/show/result_schema'

  module API
    module REST
      module ProcessingStatuses
        module Show
          # Вспомогательный модуль, подключаемый к тестам REST API метода,
          # описанного в содержащем модуле
          module SpecHelper
            # Возвращает JSON-схему значения, возвращаемого REST API методом
            # @return [Hash]
            #   JSON-схема
            def schema
              Actions::ProcessingStatuses::Show::RESULT_SCHEMA
            end
          end
        end
      end
    end
  end
end
