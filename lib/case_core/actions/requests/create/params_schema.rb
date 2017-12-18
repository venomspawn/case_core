# encoding: utf-8

module CaseCore
  module Actions
    module Requests
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
              case_id: {
                type: %i(string number boolean)
              }
            },
            required: %i(
              case_id
            )
          }
        end
      end
    end
  end
end
