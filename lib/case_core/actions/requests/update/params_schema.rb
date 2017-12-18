# encoding: utf-8

module CaseCore
  module Actions
    module Requests
      class Update
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
                type: :integer
              },
              # Исключение `case_id`
              case_id: {
                not: {}
              },
              # Исключение `created_at`
              created_at: {
                not: {}
              }
            },
            required: %i(
              id
            ),
            minProperties: 2
          }
        end
      end
    end
  end
end
