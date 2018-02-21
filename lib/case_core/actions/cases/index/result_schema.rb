# encoding: utf-8

module CaseCore
  module Actions
    module Cases
      class Index
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Модуль, предоставляющий пространство имён для константы, в которой
        # задаётся схема результатов действия родительского класса
        #
        module ResultSchema
          # Схема результатов действия
          #
          RESULT_SCHEMA = {
            type: :array,
            items: {
              type: :object,
              additionalProperties: {
                type: %i(string null)
              }
            }
          }
        end
      end
    end
  end
end
