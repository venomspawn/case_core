# frozen_string_literal: true

module CaseCore
  module Actions
    module Requests
      class Index
        # Схема параметров действия
        #
        PARAMS_SCHEMA = {
          definitions: {
            condition: {
              oneOf: [
                {
                  not: {
                    type: :object
                  }
                },
                {
                  type: :object,
                  properties: {
                    exclude: {
                      '$ref': '#/definitions/condition'
                    },
                    like: {
                      type: :string
                    },
                    min: {
                      type: %i[number string]
                    },
                    max: {
                      type: %i[number string]
                    }
                  },
                  additionalProperties: false,
                  minProperties: 1
                }
              ]
            },
            filter: {
              type: :object,
              additionalProperties: {
                '$ref': '#/definitions/condition'
              }
            },
            filters: {
              type: :array,
              items: {
                '$ref': '#/definitions/filter'
              }
            }
          },
          type: :object,
          properties: {
            id: {
              type: :string
            },
            filter: {
              oneOf: [
                {
                  '$ref': '#/definitions/filter'
                },
                {
                  '$ref': '#/definitions/filters'
                }
              ]
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
