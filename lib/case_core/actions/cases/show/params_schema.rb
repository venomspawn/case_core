# frozen_string_literal: true

module CaseCore
  module Actions
    module Cases
      class Show
        # Схема параметров действия
        PARAMS_SCHEMA = {
          type: :object,
          properties: {
            id: {
              type: %i[string number boolean]
            }
          },
          required: %i[
            id
          ]
        }.freeze
      end
    end
  end
end
