# frozen_string_literal: true

module CaseCore
  module Actions
    module Cases
      class Show
        # Схема параметров действия
        PARAMS_SCHEMA = {
          type: :object,
          properties: {
            id: {
              type: :string
            },
            names: {
              type: %i[null array],
              items: {
                type: :string,
                not: {
                  enum: %w[id type created_at]
                }
              }
            }
          },
          required: %i[
            id
          ]
        }.freeze
      end
    end
  end
end
