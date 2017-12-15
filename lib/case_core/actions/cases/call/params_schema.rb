# encoding: utf-8

module CaseCore
  module Actions
    module Cases
      class Call
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
              method: {
                type: %i(string boolean)
              },
              arguments: {
                type: :array
              }
            },
            required: %i(
              id
              method
            )
          }
        end
      end
    end
  end
end