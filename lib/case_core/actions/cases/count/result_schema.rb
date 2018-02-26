# encoding: utf-8

module CaseCore
  module Actions
    module Cases
      class Count
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Модуль, предоставляющий пространство имён для константы, в которой
        # задаётся схема результатов действия родительского класса
        #
        module ResultSchema
          # Схема результатов действия
          #
          RESULT_SCHEMA = {
            type: :object,
            properties: {
              count: {
                type: :integer,
                minimum: 0
              }
            },
            required: %i(
              count
            ),
            additionalProperties: false
          }
        end
      end
    end
  end
end
