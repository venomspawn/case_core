# frozen_string_literal: true

module CaseCore
  module Actions
    module Cases
      class Call
        # Схема параметров действия
        PARAMS_SCHEMA = {
          type: :object,
          properties: {
            id: {
              type: %i[string number boolean]
            },
            method: {
              type: %i[string boolean]
            },
            arguments: {
              type: :array
            }
          },
          required: %i[
            id
            method
          ]
        }.freeze
      end
    end
  end
end
