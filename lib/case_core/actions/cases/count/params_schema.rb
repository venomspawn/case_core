# frozen_string_literal: true

require "#{$lib}/search/definitions"

module CaseCore
  module Actions
    module Cases
      class Count
        # Схема параметров действия
        PARAMS_SCHEMA = {
          **Search::DEFINITIONS,
          type: :object,
          properties: {
            filter: {
              '$ref': '#/definitions/condition'
            },
            limit: {
              type: :integer
            },
            offset: {
              type: :integer
            }
          }
        }.freeze
      end
    end
  end
end
