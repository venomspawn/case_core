# frozen_string_literal: true

require "#{$lib}/search/definitions"

module CaseCore
  module Actions
    module Requests
      class Index
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
          },
          required: %i[
            id
          ]
        }.freeze
      end
    end
  end
end
