# frozen_string_literal: true

module CaseCore
  module Actions
    module Version
      class Show
        # Схема результатов действия
        RESULT_SCHEMA = {
          type: :object,
          properties: {
            version: {
              type: :string
            },
            modules: {
              type: :object,
              additionalProperties: {
                type: :string
              }
            }
          },
          required: %i[
            version
          ],
          additionalProperties: false
        }.freeze
      end
    end
  end
end
