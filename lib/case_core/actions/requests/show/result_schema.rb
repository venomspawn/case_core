# frozen_string_literal: true

module CaseCore
  module Actions
    module Requests
      class Show
        # Схема результатов действия
        #
        RESULT_SCHEMA = {
          type: :object,
          properties: {
            id: {
              type: :integer
            },
            case_id: {
              type: %i[number string boolean]
            },
            created_at: {
              type: :any
            }
          },
          required: %i[
            id
            case_id
            created_at
          ],
          additionalProperties: {
            type: %i[number string boolean null]
          }
        }.freeze
      end
    end
  end
end
