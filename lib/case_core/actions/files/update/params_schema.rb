# frozen_string_literal: true

module CaseCore
  module Actions
    module Files
      class Update
        # Выражение для шестнадцатеричной цифры
        HEX = '[a-fA-F0-9]'

        # Регулярное выражение для проверки на формат UUID
        UUID_FORMAT = /^#{HEX}{8}-#{HEX}{4}-#{HEX}{4}-#{HEX}{4}-#{HEX}{12}$/

        # JSON-схема параметров действия
        PARAMS_SCHEMA = {
          type: :object,
          properties: {
            id: {
              type: :string,
              pattern: UUID_FORMAT
            },
            content: {
              not: { type: :null }
            }
          },
          required: %i[
            id
            content
          ],
          additionalProperties: false
        }.freeze
      end
    end
  end
end
