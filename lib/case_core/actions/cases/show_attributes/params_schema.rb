# encoding: utf-8

module CaseCore
  module Actions
    module Cases
      class ShowAttributes
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
                type: %i(string number boolean)
              },
              names: {
                type: %i(null array),
                items: {
                  type: %i(string number boolean),
                  not: {
                    enum: %w(id type created_at)
                  }
                }
              }
            },
            required: %i(
              id
            ),
            additionalProperties: false
          }
        end
      end
    end
  end
end
