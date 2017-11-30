# encoding: utf-8

module CaseCore
  module Actions
    module Registers
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
            type: :object,
            properties: {
              id: {
                type: :integer
              },
              institution_rguid: {
                type: %i[string integer null]
              },
              office_id: {
                type: %i[string integer null]
              },
              back_office_id: {
                type: %i[string integer null]
              },
              register_type: {
                type: :string
              },
              exported: {
                type: %i[boolean null]
              },
              exporter_id: {
                type: %i[string integer null]
              },
              exported_at: {
                type: :any
              },
              items_count: {
                type: :integer
              },
              items: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: {
                      type: %i[string integer]
                    },
                    service_id: {
                      type: %i[string integer null]
                    },
                    applicant_id: {
                      type: %i[string integer null]
                    },
                    created_at: {
                      type: :any
                    },
                    state: {
                      type: %i[string null]
                    }
                  },
                  required: %i[
                    id
                    service_id
                    applicant_id
                    created_at
                    state
                  ],
                  additionalProperties: false
                }
              }
            },
            required: %i[
              id
              institution_rguid
              office_id
              back_office_id
              register_type
              exported
              exporter_id
              exported_at
              items_count
              items
            ],
            additionalProperties: false
          }
        end
      end
    end
  end
end
