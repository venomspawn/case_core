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
            type: :object,
            properties: {
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
                        min: {
                          type: %i(number string)
                        }
                      },
                      required: %i(
                        min
                      ),
                      additionalProperties: false
                    },
                    {
                      type: :object,
                      properties: {
                        max: {
                          type: %i(number string)
                        }
                      },
                      required: %i(
                        max
                      ),
                      additionalProperties: false
                    },
                    {
                      type: :object,
                      properties: {
                        min: {
                          type: %i(number string)
                        },
                        max: {
                          type: %i(number string)
                        }
                      },
                      required: %i(
                        min
                        max
                      ),
                      additionalProperties: false
                    },
                    {
                      type: :object,
                      properties: {
                        exclude: {
                          oneOf: [
                            {
                              not: {
                                type: :object
                              }
                            },
                            {
                              type: :object,
                              properties: {
                                min: {
                                  type: %i(number string)
                                }
                              },
                              required: %i(
                                min
                              ),
                              additionalProperties: false
                            },
                            {
                              type: :object,
                              properties: {
                                max: {
                                  type: %i(number string)
                                }
                              },
                              required: %i(
                                max
                              ),
                              additionalProperties: false
                            },
                            {
                              type: :object,
                              properties: {
                                min: {
                                  type: %i(number string)
                                },
                                max: {
                                  type: %i(number string)
                                }
                              },
                              required: %i(
                                min
                                max
                              ),
                              additionalProperties: false
                            }
                          ]
                        }
                      },
                      required: %i(
                        exclude
                      ),
                      additionalProperties: false
                    }
                  ]
                }
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
              }
            }
          }
        end
      end
    end
  end
end
