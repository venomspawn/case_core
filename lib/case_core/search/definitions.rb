# frozen_string_literal: true

module CaseCore
  # rubocop: disable Metrics/ModuleLength
  module Search
    # Определения, используемые JSON-схемами
    DEFINITIONS = {
      definitions: {
        value: {
          type: %i[string integer number array boolean null],
          items: {
            type: %i[string integer number boolean null]
          }
        },
        like: {
          type: :object,
          properties: {
            like: {
              type: :string
            }
          },
          required: %i[
            like
          ],
          additionalProperties: false
        },
        range: {
          type: :object,
          properties: {
            min: {
              type: %i[number string]
            },
            max: {
              type: %i[number string]
            }
          },
          additionalProperties: false,
          minProperties: 1
        },
        exclude: {
          type: :object,
          properties: {
            exclude: {
              oneOf: [
                {
                  '$ref': '#/definitions/value'
                },
                {
                  '$ref': '#/definitions/like'
                },
                {
                  '$ref': '#/definitions/range'
                }
              ]
            }
          },
          required: %i[
            exclude
          ],
          additionalProperties: false
        },
        simple: {
          type: :object,
          additionalProperties: {
            oneOf: [
              {
                '$ref': '#/definitions/value'
              },
              {
                '$ref': '#/definitions/like'
              },
              {
                '$ref': '#/definitions/range'
              },
              {
                '$ref': '#/definitions/exclude'
              }
            ]
          },
          minProperties: 1
        },
        or: {
          type: :object,
          properties: {
            or: {
              '$ref': '#/definitions/conditions'
            }
          },
          required: %i[
            or
          ],
          additionalProperties: false
        },
        and: {
          type: :object,
          properties: {
            and: {
              '$ref': '#/definitions/conditions'
            }
          },
          required: %i[
            and
          ],
          additionalProperties: false
        },
        condition: {
          oneOf: [
            {
              '$ref': '#/definitions/simple'
            },
            {
              '$ref': '#/definitions/or'
            },
            {
              '$ref': '#/definitions/and'
            }
          ]
        },
        conditions: {
          type: :array,
          items: {
            '$ref': '#/definitions/condition'
          },
          minItems: 1
        }
      }
    }.freeze
  end
  # rubocop: enable Metrics/ModuleLength
end
