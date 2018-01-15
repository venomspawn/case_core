# encoding: utf-8

module CaseCore
  module Actions
    module Cases
      class ShowAttributes
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
            additionalProperties: {
              type: %i(number string boolean null)
            }
          }
        end
      end
    end
  end
end