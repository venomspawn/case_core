# encoding: utf-8

module MSPCase
  module EventProcessors
    class RespondingSTOMPMessageProcessor
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Вспомогательный модуль, предназначенный для включения в содержащий
      # класс
      #
      module Helpers
        # Проверяет, что аргумент является объектом класса `Stomp::Message`
        #
        # @param [Object] message
        #   аргумент
        #
        # @raise [ArgumentError]
        #   если аргумент не является объектом класса `Stomp::Message`
        #
        def check_message!(message)
          raise Errors::Message::BadType unless message.is_a?(Stomp::Message)
        end

        # Проверяет, что аргумент соответствует JSON-схеме
        #
        # @param [Object] response_data
        #   аргумент
        #
        # @raise [JSON::Schema::ValidationError]
        #   если аргумент не соответствует JSON-схеме
        #
        def check_response_data!(response_data)
          JSON::Validator.validate!(ResponseDataSchema::SCHEMA, response_data)
        end

        # Проверяет, что поле `type` записи заявки равно `msp_case`
        #
        # @param [CaseCore::Models::Case] c4s3
        #   запись заявки
        #
        # @raise [RuntimeError]
        #   если поле `type` записи заявки не равно `msp_case`
        #
        def check_case_type!(c4s3)
          raise Errors::Case::BadType.new(c4s3) unless c4s3.type == 'msp_case'
        end

        # Проверяет, что статус заявки `processing`
        #
        # @param [CaseCore::Models::Case] c4s3
        #   запись заявки
        #
        # @param [Hash] case_attributes
        #   ассоциативный массив атрибутов заявки
        #
        # @raise [RuntimeError]
        #   если статус заявки отличен от `processing`
        #
        def check_case_status!(c4s3, case_attributes)
          status = case_attributes[:status]
          return if status == 'processing'
          raise Errors::Case::BadStatus.new(c4s3, status)
        end

        # Проверяет, что запись запроса найдена
        #
        # @param [NilClass, CaseCore::Models::Request] request
        #   запись запроса или `nil`
        #
        # @param [#to_s] original_message_id
        #   идентификатор исходного сообщения STOMP
        #
        # @raise [RuntimeError]
        #   если аргумент равен `nil`
        #
        def check_request!(request, original_message_id)
          return unless request.nil?
          raise Errors::Request::NotFound.new(original_message_id)
        end

        # Возвращает запрос Sequel на извлечение всех записей заявок
        #
        # @return [Sequel::Dataset]
        #   результирующий запрос Sequel
        #
        def cases
          CaseCore::Models::Case.dataset
        end

        # Возвращает запрос Sequel на извлечение всех записей запросов
        #
        # @return [Sequel::Dataset]
        #   результирующий запрос Sequel
        #
        def requests
          CaseCore::Models::Request.dataset
        end

        # Возвращает запрос Sequel на извлечение всех записей атрибутов заявок
        #
        # @return [Sequel::Dataset]
        #   результирующий запрос Sequel
        #
        def case_attributes
          CaseCore::Models::CaseAttribute.dataset
        end

        # Возвращает запрос Sequel на извлечение всех записей атрибутов запросов
        #
        # @return [Sequel::Dataset]
        #   результирующий запрос Sequel
        #
        def request_attributes
          CaseCore::Models::RequestAttribute.dataset
        end
      end
    end
  end
end
