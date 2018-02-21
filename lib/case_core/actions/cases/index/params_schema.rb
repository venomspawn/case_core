# encoding: utf-8

module CaseCore
  module Actions
    module Cases
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
            }
          }
        end
      end
    end
  end
end
