# encoding: utf-8

module CaseCore
  module Actions
    module Registers
      class Show
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
                type: %i(string numeric)
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
