# frozen_string_literal: true

module CaseCore
  need 'actions/uuid_format'

  module Actions
    module Documents
      class Index
        # Схема результатов действия
        RESULT_SCHEMA = {
          type: :array,
          items: {
            type: :object,
            properties: {
              id: {
                type: %i[string number boolean]
              },
              case_id: {
                type: %i[string number boolean]
              },
              title: {
                type: %i[string null]
              },
              direction: {
                type: %i[string null]
              },
              correct: {
                type: %i[boolean null]
              },
              provided_as: {
                type: %i[string null]
              },
              size: {
                type: %i[string null]
              },
              last_modified: {
                type: %i[string null]
              },
              quantity: {
                type: %i[integer null]
              },
              mime_type: {
                type: %i[string null]
              },
              filename: {
                type: %i[string null]
              },
              provided: {
                type: %i[boolean null]
              },
              in_document_id: {
                type: %i[string number boolean null]
              },
              fs_id: {
                type: :string,
                pattern: UUID_FORMAT
              },
              created_at: {
                type: :any
              }
            },
            required: %i[
              id
              case_id
              title
              direction
              correct
              provided_as
              size
              last_modified
              quantity
              mime_type
              filename
              provided
              in_document_id
              fs_id
              created_at
            ],
            additionalProperties: false
          }
        }.freeze
      end
    end
  end
end
