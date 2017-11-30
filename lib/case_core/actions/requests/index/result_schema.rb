# encoding: utf-8

module CaseCore
  module Actions
    module Requests
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
              properties: {
                id: {
                  type: :integer
                },
                created_at: {
                  type: :string
                }
              }
            }
          }
        end
      end
    end
  end
end
