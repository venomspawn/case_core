# frozen_string_literal: true

module CaseCore
  need 'search/definitions'

  module Actions
    module Cases
      class Index
        # Схема параметров действия
        PARAMS_SCHEMA = {
          **Search::DEFINITIONS,
          type: :object,
          properties: {
            filter: {
              '$ref': '#/definitions/condition'
            },
            fields: {
              type: %i[string array],
              items: {
                type: :string
              }
            },
            limit: {
              type: :integer
            },
            offset: {
              type: :integer
            },
            order: {
              type: :object,
              additionalProperties: {
                type: :string,
                enum: %w[asc desc]
              },
              minProperties: 1
            }
          }
        }.freeze
      end
    end
  end
end
