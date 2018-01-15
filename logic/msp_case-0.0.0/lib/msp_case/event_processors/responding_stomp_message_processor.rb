# encoding: utf-8

Dir["#{__dir__}/responding_stomp_message_processor/*.rb"].each(&method(:load))

module MSPCase
  module EventProcessors
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Класс обработчиков события `on_responding_stomp_message` на ответное
    # сообщение STOMP
    #
    class RespondingSTOMPMessageProcessor
      include Helpers

      # Инициализирует объект класса
      #
      # @param [Stomp::Message] message
      #   объект с информацией об ответном сообщении STOMP
      #
      # @raise [ArgumentError]
      #   если аргумент `message` не является объектом класса `Stomp::Message`
      #
      # @raise [JSON::ParserError]
      #   если тело сообщения STOMP не является JSON-строкой
      #
      # @raise [JSON::Schema::ValidationError]
      #   если структура, восстановленная из тела сообщения STOMP, не
      #   удовлетворяет JSON-схеме
      #
      def initialize(message)
        check_message!(message)
        response_data = JSON.parse(message.body, symbolize_names: true)
        check_response_data!(response_data)
        @response_data = response_data
      end

      # Обрабатывает ответное сообщение STOMP
      #
      # @raise [RuntimeError]
      #   если запись запроса не найдена
      #
      # @raise [RuntimeError]
      #   если поле `type` записи заявки не равно `msp_case`
      #
      # @raise [RuntimeError]
      #   если статус заявки отличен от `processing`
      #
      def process
        request = find_request!
        c4s3 = request.case
        check_case_type!(c4s3)
        case_attributes = extract_case_attributes(c4s3.id)
        check_case_status!(c4s3, case_attributes)
        update_request_attributes(request)
        update_case_attributes(c4s3.id, case_attributes)
      end

      private

      # Ассоциативный массив с данными ответного сообщения STOMP
      #
      # @return [Hash]
      #   ассоциативный массив с данными ответного сообщения STOMP
      #
      attr_reader :response_data

      # Возвращает идентификатор исходного сообщения, на которое пришёл ответ
      #
      # @return [String]
      #   идентификатор исходного сообщения
      #
      def original_message_id
        response_data[:id]
      end

      # Возвращает тип сообщения
      #
      # @return [String]
      #   тип сообщения
      #
      def response_format
        response_data[:format]
      end

      # Возвращает содержимое ответа
      #
      # @return [String]
      #   содержимое ответа
      #
      def response_content
        response_data[:content][:special_data]
      end

      # Возвращает запись запроса
      #
      # @return [CaseCore::Models::Request]
      #   запись запроса
      #
      # @raise [RuntimeError]
      #   если запись запроса не найдена
      #
      def find_request!
        CaseCore::Actions::Requests
          .find(msp_message_id: original_message_id)
          .tap { |request| check_request!(request, original_message_id) }
      end

      # Названия требуемых атрибутов заявки
      #
      CASE_ATTRS = %w(status issue_location_type)

      # Извлекает требуемые атрибуты заявки из соответствующих записей и
      # возвращает ассоциативный массив атрибутов заявки
      #
      # @param [String] case_id
      #   идентификатор записи заявки
      #
      # @return [Hash{Symbol => Object}]
      #   результирующий ассоциативный массив
      #
      def extract_case_attributes(case_id)
        CaseCore::Actions::Cases
          .show_attributes(id: case_id, names: CASE_ATTRS)
      end

      # Обновляет атрибуты запроса
      #
      # @param [CaseCore::Models::Request] request
      #   запись запроса
      #
      def update_request_attributes(request)
        CaseCore::Actions::Requests
          .update(id: request.id, response_content: response_content)
      end

      # Обновляет атрибуты заявки
      #
      # @param [String] case_id
      #   идентификатор записи заявки
      #
      # @param [Hash{Symbol => Object}] case_attributes
      #   ассоциативный массив атрибутов заявки
      #
      def update_case_attributes(case_id, case_attributes)
        attributes = new_case_attributes(case_id, case_attributes)
        return if attributes.empty?
        CaseCore::Actions::Cases.update(id: case_id, **attributes)
      end

      # Возвращает ассоциативный массив новых атрибутов заявки
      #
      # @param [String] case_id
      #   идентификатор записи заявки
      #
      # @param [Hash{Symbol => Object}] case_attributes
      #   ассоциативный массив атрибутов заявки
      #
      # @return [Hash]
      #   ассоциативный массив новых атрибутов заявки
      #
      def new_case_attributes(case_id, case_attributes)
        attributes = case response_format
                     when 'EXCEPTION'
                       { status: 'error' }
                     when 'REJECTION', 'RESPONSE'
                       case case_attributes[:issue_location_type]
                       when 'mfc'
                         { status: 'issuance' }
                       when 'email'
                         { status: 'closed', closed_at: Time.now }
                       end
                     end
        attributes || {}
      end
    end
  end
end