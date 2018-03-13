# frozen_string_literal: true

module CaseCore
  module Actions
    module Cases
      class Update
        # Схема параметров действия
        PARAMS_SCHEMA = {
          type: :object,
          properties: {
            id: {
              type: %i[string array],
              items: {
                type: :string
              }
            },
            # Исключение `type`
            type: {
              not: {}
            },
            # Исключение `created_at`
            created_at: {
              not: {}
            }
          },
          required: %i[
            id
          ],
          minProperties: 2
        }.freeze
      end
    end
  end
end
