# encoding: utf-8

module MSPCase
  module EventProcessors
    class RespondingSTOMPMessageProcessor
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Модуль, предоставляющий константу `SCHEMA`, в которой описана схема
      # структуры тела сообщения STOMP
      #
      module ResponseDataSchema
        # Схема структуры тела сообщения STOMP
        #
        SCHEMA = {
          type: :object,
          properties: {
            id: {
              type: :string
            },
            format: {
              type: :string,
              enum: %w(EXCEPTION REJECTION RESPONSE)
            },
            content: {
              type: :object,
              properties: {
                special_data: {
                  type: :string
                }
              },
              required: %i(
                special_data
              )
            }
          },
          required: %i(
            id
            format
            content
          )
        }
      end
    end
  end
end
