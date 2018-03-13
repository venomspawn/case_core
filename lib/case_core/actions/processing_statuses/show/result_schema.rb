# frozen_string_literal: true

module CaseCore
  module Actions
    module ProcessingStatuses
      class Show
        # Схема результатов действия
        RESULT_SCHEMA = {
          oneOf: [
            {
              type: :object,
              properties: {
                status: {
                  type: :string,
                  enum: %w[ok]
                }
              },
              required: %i[
                status
              ],
              additionalProperties: false
            },
            {
              type: :object,
              properties: {
                status: {
                  type: :string,
                  enum: %w[error]
                },
                error_class: {
                  type: :string
                },
                error_text: {
                  type: :string
                }
              },
              required: %i[
                status
                error_class
                error_text
              ],
              additionalProperties: false
            }
          ]
        }.freeze
      end
    end
  end
end
