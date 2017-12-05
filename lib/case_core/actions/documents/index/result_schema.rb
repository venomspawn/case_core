# encoding: utf-8

module CaseCore
  module Actions
    module Documents
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
                  type: %i(string number boolean)
                },
                case_id: {
                  type: %i(string number boolean)
                },
                title: {
                  type: %i(string null)
                },
                direction: {
                  type: %i(string null)
                },
                correct: {
                  type: %i(boolean null)
                },
                provided_as: {
                  type: %i(string null)
                },
                size: {
                  type: %i(string null)
                },
                last_modified: {
                  type: %i(string null)
                },
                quantity: {
                  type: %i(integer null)
                },
                mime_type: {
                  type: %i(string null)
                },
                filename: {
                  type: %i(string null)
                },
                provided: {
                  type: %i(boolean null)
                },
                in_document_id: {
                  type: %i(string number boolean null)
                },
                fs_id: {
                  type: %i(string number boolean null)
                },
                created_at: {
                  type: :any
                }
              },
              required: %i(
                id
                case_id
                title
                direction
                correct
                provided_as
                size
                last_modified
                quantity
                mime_type
                filename
                provided
                in_document_id
                fs_id
                created_at
              ),
              additionalProperties: false
            }
          }
        end
      end
    end
  end
end
