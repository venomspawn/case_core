# encoding: utf-8

require 'securerandom'

Dir["#{__dir__}/case_creation_processor/*.rb"].each(&method(:load))

module MSPCase
  module EventProcessors
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Класс обработчиков события `on_case_creation` заявки. Обработчик
    # выставляет начальный статус заявки `processing` и создаёт запрос в
    # очередь.
    #
    class CaseCreationProcessor
      include Helpers

      # Инициализирует объект класса
      #
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      #
      # @raise [ArgumentError]
      #   если аргумент `c4s3` не является объектом класса
      #   `CaseCore::Models::Case`
      #
      # @raise [RuntimeError]
      #   значение поля `type` записи заявки не равно `msp_case`
      #
      # @raise [RuntimeError]
      #   если заявка обладает выставленным статусом
      #
      def initialize(c4s3)
        check_case!(c4s3)
        check_case_type!(c4s3)
        @c4s3 = c4s3
        check_case_status!(c4s3, case_attributes)
      end

      # Выполняет обработку
      #
      def process
        update_case_attributes
        create_request
      end

      private

      # Запись заявки
      #
      # @return [CaseCore::Models::Case]
      #   запись заявки
      #
      attr_reader :c4s3

      # Возвращает ассоциативный массив атрибутов заявки
      #
      # @return [Hash]
      #   ассоциативный массив атрибутов заявки
      #
      def case_attributes
        @case_attributes ||= extract_case_attributes
      end

      # Возвращает значение атрибута `special_data` заявки
      #
      # @return [NilClass, String]
      #    значение атрибута `special_data` заявки
      #
      def case_special_data
        case_attributes[:special_data]
      end

      # Возвращает значение атрибута `service_id` заявки
      #
      # @return [NilClass, String]
      #    значение атрибута `service_id` заявки
      #
      def case_service_id
        case_attributes[:service_id]
      end

      # Названия требуемых атрибутов заявки
      #
      CASE_ATTRS = %w(status special_data service_id)

      # Извлекает требуемые атрибуты заявки из соответствующих записей и
      # возвращает ассоциативный массив атрибутов заявки
      #
      # @return [Hash{Symbol => Object}]
      #   результирующий ассоциативный массив
      #
      def extract_case_attributes
        CaseCore::Actions::Cases
          .show_attributes(id: c4s3.id, names: CASE_ATTRS)
      end

      # Обновляет атрибуты заявки
      #
      def update_case_attributes
        CaseCore::Actions::Cases.update(id: c4s3.id, status: 'processing')
      end

      # Создаёт запись запроса, ассоциируя её с записью запроса, и публикует
      # запрос в очередь
      #
      def create_request
        message_id = SecureRandom.uuid
        request = CaseCore::Actions::Requests
                  .create(case_id: c4s3.id, msp_message_id: message_id)
        publish_message(message_id)
      end

      # Возвращает ассоциативный массив с информацией о запросе
      #
      # @param [String] message_id
      #   идентификатор сообщения
      #
      def message_data(message_id)
        {
          id: message_id,
          content: {
            special_data: case_special_data,
            service_id:   case_service_id
          }
        }
      end

      # Название очереди, в которую публикуется сообщение STOMP
      #
      QUEUE_NAME = 'smev3.queue'

      # Публикует запрос в очередь
      #
      # @param [String] message_id
      #   идентификатор сообщения
      #
      def publish_message(message_id)
        message = message_data(message_id).to_json
        CaseCore::API::STOMP::Controller.publish(QUEUE_NAME, message, {})
      end
    end
  end
end
