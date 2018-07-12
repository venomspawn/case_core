# frozen_string_literal: true

module CaseCore
  module Actions
    module Files
      class Create
        # Схема результатов действия
        RESULT_SCHEMA = {
          type: :object,
          properties: {
            id: {
              type: :string
            }
          },
          required: %i[
            id
          ],
          additionalProperties: false
        }.freeze
      end
    end
  end
end
