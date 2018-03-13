# frozen_string_literal: true

module CaseCore
  module Actions
    module Requests
      class Create
        # Схема параметров действия
        PARAMS_SCHEMA = {
          type: :object,
          properties: {
            case_id: {
              type: %i[string number boolean]
            }
          },
          required: %i[
            case_id
          ]
        }.freeze
      end
    end
  end
end
