# frozen_string_literal: true

module CaseCore
  module Actions
    module Cases
      class ShowAttributes
        # Схема результатов действия
        #
        RESULT_SCHEMA = {
          type: :object,
          additionalProperties: {
            type: %i[number string boolean null]
          }
        }.freeze
      end
    end
  end
end
