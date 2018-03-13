# frozen_string_literal: true

module CaseCore
  module Actions
    module Cases
      class ShowAttributes
        # Схема параметров действия
        #
        PARAMS_SCHEMA = {
          type: :object,
          properties: {
            id: {
              type: %i[string number boolean]
            },
            names: {
              type: %i[null array],
              items: {
                type: %i[string number boolean],
                not: {
                  enum: %w[id type created_at]
                }
              }
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
