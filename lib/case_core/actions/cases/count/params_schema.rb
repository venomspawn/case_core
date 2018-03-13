# frozen_string_literal: true

module CaseCore
  module Actions
    module Cases
      class Count
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
