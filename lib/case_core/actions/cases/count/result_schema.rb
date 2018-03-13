# frozen_string_literal: true

module CaseCore
  module Actions
    module Cases
      class Count
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
          required: %i[
            count
          ],
          additionalProperties: false
        }.freeze
      end
    end
  end
end
