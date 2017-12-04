# encoding: utf-8

module CaseCore
  module Actions
    module Cases
      class Create
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Модуль, предоставляющий пространство имён для константы, в которой
        # задаётся схема параметров действия родительского класса
        #
        module ParamsSchema
          # Схема параметров действия
          #
          PARAMS_SCHEMA = {
            type: :object,
            properties: {
              id: {
                type: %i(string number boolean null)
              },
              type: {
                type: %i(string number boolean)
              },
              documents: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: {
                      type: %i(string number boolean null)
                    },
                    title: {
                      type: %i(string null)
                    },
                    direction: {
                      oneOf: [
                        {
                          type: :string,
                          enum: %w(input output)
                        },
                        {
                          type: :null
                        }
                      ]
                    },
                    correct: {
                      type: %i(boolean null)
                    },
                    provided_as: {
                      oneOf: [
                        {
                          type: :string,
                          enum: %w(original copy notarized_copy doc_list)
                        },
                        {
                          type: :null
                        }
                      ]
                    },
                    size: {
                      type: %i(string number null)
                    },
                    last_modified: {
                      type: %i(string number null)
                    },
                    quantity: {
                      type: %i(integer null)
                    },
                    mime_type: {
                      type: %i(string null)
                    },
                    filename: {
                      type: %i(string null)
                    },
                    provided: {
                      type: %i(boolean null)
                    },
                    in_document_id: {
                      type: %i(string number boolean null)
                    },
                    fs_id: {
                      type: %i(string number boolean null)
                    },
                    created_at: {
                      type: %i(string number boolean null)
                    }
                  },
                  additionalProperties: false
                }
              }
            },
            required: %i(
              type
            )
          }
        end
      end
    end
  end
end
