# frozen_string_literal: true

module CaseCore
  module Actions
    module Requests
      class Index
        # Схема результатов действия
        RESULT_SCHEMA = {
          type: :array,
          items: {
            type: :object,
            properties: {
              id: {
                type: :integer
              }
            },
            additonalProperties: {
              type: :string
            }
          }
        }.freeze
      end
    end
  end
end
