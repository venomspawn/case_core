# frozen_string_literal: true

module CaseCore
  module Actions
    module Cases
      class Index
        # Схема результатов действия
        #
        RESULT_SCHEMA = {
          type: :array,
          items: {
            type: :object,
            additionalProperties: {
              type: %i[string null]
            }
          }
        }.freeze
      end
    end
  end
end
