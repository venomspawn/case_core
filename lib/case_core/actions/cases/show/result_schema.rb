# frozen_string_literal: true

module CaseCore
  module Actions
    module Cases
      class Show
        # Схема результатов действия
        RESULT_SCHEMA = {
          type: :object,
          properties: {
            id: {
              type: %i[number string boolean]
            },
            type: {
              type: %i[number string boolean]
            },
            created_at: {
              type: :any
            }
          },
          additionalProperties: {
            type: %i[number string boolean null]
          }
        }.freeze
      end
    end
  end
end
