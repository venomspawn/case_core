# encoding: utf-8

module CaseCore
  module Actions
    module ProcessingStatuses
      class Show
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Модуль, предоставляющий пространство имён для константы, в которой
        # задаётся схема результатов действия родительского класса
        #
        module ResultSchema
          # Схема результатов действия
          #
          RESULT_SCHEMA = {
            oneOf: [
              {
                type: :object,
                properties: {
                  status: {
                    type: :string,
                    enum: %w(ok)
                  }
                },
                required: %i(
                  status
                ),
                additionalProperties: false
              },
              {
                type: :object,
                properties: {
                  status: {
                    type: :string,
                    enum: %w(error)
                  },
                  error_class: {
                    type: :string
                  },
                  error_text: {
                    type: :string
                  }
                },
                required: %i(
                  status
                  error_class
                  error_text
                ),
                additionalProperties: false
              }
            ]
          }
        end
      end
    end
  end
end
