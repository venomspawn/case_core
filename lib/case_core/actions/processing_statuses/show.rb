# frozen_string_literal: true

module CaseCore
  need 'actions/base/action'

  module Actions
    module ProcessingStatuses
      # Класс действий над записями статусов обработки сообщений STOMP,
      # предоставляющий метод `show`, который возвращает информацию о статусе
      # обработки сообщения STOMP с данным значением заголовка `x_message_id`
      class Show < Base::Action
        require_relative 'show/errors'
        require_relative 'show/params_schema'

        # Статус успешной обработки
        OK = 'ok'

        # Возвращает ассоциативный массив с информацией о статусе обработки
        # сообщения STOMP с данным значением заголовка `x_message_id`
        # @return [Hash]
        #   результирующий ассоциативный массив
        def show
          record.status == OK ? record.values.slice(:status) : record.values
        end

        private

        # Возвращает запись статуса обработки сообщения STOMP
        # @return [CaseCore::Models::ProcessingStatus]
        #   запись статуса обработки сообщения STOMP
        # @raise [Sequel::NoMatchingRow]
        #   если запись заявки не найдена
        def record
          @record ||= find_record!
        end

        # Ищет запись статуса обработки сообщения STOMP по атрибуту
        # `message_id` и возвращает её
        # @return [CaseCore::Models::ProcessingStatus]
        #   запись статуса обработки сообщения STOMP
        # @raise [Sequel::NoMatchingRow]
        #   если запись заявки не найдена
        def find_record!
          Models::ProcessingStatus
            .select(:status, :error_class, :error_text)
            .first(message_id: message_id)
            .tap { |result| raise Errors::NotFound, message_id if result.nil? }
        end

        # Возвращает значение атрибута `message_id` ассоциативного массива
        # параметров
        # @return [Object]
        #   результирующее значение
        def message_id
          params[:message_id]
        end
      end
    end
  end
end
