# frozen_string_literal: true

module CaseCore
  module Actions
    module ProcessingStatuses
      class Show
        # Схема параметров действия
        #
        PARAMS_SCHEMA = {
          type: :object,
          properties: {
            message_id: {
              type: %i[string number boolean]
            }
          },
          required: %i[
            message_id
          ]
        }.freeze
      end
    end
  end
end
