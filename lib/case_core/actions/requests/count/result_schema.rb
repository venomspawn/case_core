# frozen_string_literal: true

module CaseCore
  module Actions
    module Requests
      class Count
        # Схема результатов действия
        RESULT_SCHEMA = {
          type: :object,
          properties: {
            count: {
              type: :integer
            }
          },
          required: %i[
            count
          ]
        }.freeze
      end
    end
  end
end
