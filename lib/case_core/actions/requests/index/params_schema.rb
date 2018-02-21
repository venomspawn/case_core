# encoding: utf-8

module CaseCore
  module Actions
    module Requests
      class Index
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Модуль, предоставляющий пространство имён для константы, в которой
        # задаётся схема параметров действия родительского класса
        #
        module ParamsSchema
          # Схема параметров действия
          #
          PARAMS_SCHEMA = {
            definitions: {
              filter: {
                type: :object,
                additionalProperties: {
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
                          '$ref': '#/definitions/filter'
                        },
                        like: {
                          type: :string
                        },
                        min: {
                          type: %i(number string)
                        },
                        max: {
                          type: %i(number string)
                        }
                      },
                      additionalProperties: false,
                      minProperties: 1
                    }
                  ]
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
                type: %i(string array),
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
                  enum: %w(asc desc)
                },
                minProperties: 1
              }
            },
            required: %i(
              id
            )
          }
        end
      end
    end
  end
end
