# frozen_string_literal: true

module CaseCore
  need 'actions/requests/index/result_schema'

  module API
    module REST
      module Requests
        module Index
          # Вспомогательный модуль, подключаемый к тестам REST API метода,
          # описанного в содержащем модуле
          module SpecHelper
            # Возвращает JSON-схему значения, возвращаемого REST API методом
            # @return [Hash]
            #   JSON-схема
            def schema
              Actions::Requests::Index::RESULT_SCHEMA
            end
          end
        end
      end
    end
  end
end
