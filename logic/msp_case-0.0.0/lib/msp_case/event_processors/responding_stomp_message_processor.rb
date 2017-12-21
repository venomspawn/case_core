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
      def process
        request_id = find_request_id!
        c4s3 = find_case(request_id)
        check_case_type!(c4s3)
        update_request_attributes(request_id)
        update_case_attributes(c4s3.id)
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

      # Возвращает идентификатор записи запроса
      #
      # @return [Integer]
      #   идентификатор записи запроса
      #
      # @raise [Sequel::NoMatchingRow]
      #   если запись запроса не найдена
      #
      def find_request_id!
        attribute = request_attributes
                    .where(name: 'msp_message_id', value: original_message_id)
                    .select(:request_id)
                    .naked
                    .first!
        attribute[:request_id]
      end

      # Возвращает запись заявки, ассоциированной с записью запроса
      #
      # @return [CaseCore::Models::Case]
      #   запись заявки
      #
      def find_case(request_id)
        case_id_dataset = requests.select(:case_id).where(id: request_id)
        cases.where(id: case_id_dataset).first
      end

      # Обновляет атрибуты запроса
      #
      # @param [Integer] request_id
      #   идентификатор записи запроса
      #
      def update_request_attributes(request_id)
        CaseCore::Actions::Requests
          .update(id: request_id, response_content: response_content)
      end

      # Обновляет атрибуты заявки
      #
      # @param [String] case_id
      #   идентификатор записи заявки
      #
      def update_case_attributes(case_id)
        attributes = new_case_attributes(case_id)
        return if attributes.empty?
        CaseCore::Actions::Cases.update(id: case_id, **attributes)
      end

      # Возвращает ассоциативный массив новых атрибутов заявки
      #
      # @param [String] case_id
      #   идентификатор записи заявки
      #
      # @return [Hash]
      #   ассоциативный массив новых атрибутов заявки
      #
      def new_case_attributes(case_id)
        attributes = case response_format
                     when 'EXCEPTION'
                       { status: 'error' }
                     when 'REJECTION', 'RESPONSE'
                       case case_issue_location_type(case_id)
                       when 'mfc'
                         { status: 'issuance' }
                       when 'email'
                         { status: 'closed', closed_at: Time.now }
                       end
                     end
        attributes || {}
      end

      # Возвращает значение атрибута `issue_location_type` заявки
      #
      # @param [String] case_id
      #   идентификатор записи заявки
      #
      # @return [NilClass, String]
      #   результирующее значение
      #
      def case_issue_location_type(case_id)
        attribute = case_attributes
                    .select(:value)
                    .where(case_id: case_id, name: 'issue_location_type')
                    .naked
                    .first
        attribute ||= {}
        attribute[:value]
      end
    end
  end
end
