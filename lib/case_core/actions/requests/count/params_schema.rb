# frozen_string_literal: true

module CaseCore
  need 'search/definitions'

  module Actions
    module Requests
      class Count
        # Схема параметров действия
        PARAMS_SCHEMA = {
          **Search::DEFINITIONS,
          type: :object,
          properties: {
            id: {
              type: :string
            },
            filter: {
              '$ref': '#/definitions/condition'
            },
            limit: {
              type: :integer
            },
            offset: {
              type: :integer
            }
          },
          required: %i[
            id
          ]
        }.freeze
      end
    end
  end
end
