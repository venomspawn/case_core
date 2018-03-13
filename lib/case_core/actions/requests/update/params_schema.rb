# frozen_string_literal: true

module CaseCore
  module Actions
    module Requests
      class Update
        # Схема параметров действия
        #
        PARAMS_SCHEMA = {
          type: :object,
          properties: {
            id: {
              type: :integer
            },
            # Исключение `case_id`
            case_id: {
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
