# encoding: utf-8

module CaseCore
  module Actions
    module ProcessingStatuses
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
              message_id: {
                type: %i(string numeric)
              }
            },
            required: %i(
              message_id
            )
          }
        end
      end
    end
  end
end
