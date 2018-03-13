# frozen_string_literal: true

module CaseCore
  module Models
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Модель статуса обработки сообщения STOMP
    #
    # @!attribute id
    #   Идентификатор записи
    #
    #   @return [Integer] id
    #     идентификатор записи
    #
    #
    # @!attribute message_id
    #   Идентификатор сообщения STOMP (значение заголовка `x_message_id`)
    #
    #   @return [String]
    #     идентификатор сообщения STOMP (значение заголовка `x_message_id`)
    #
    #   @return [NilClass]
    #     в случае, если у сообщения STOMP не был указан заголовок
    #     `x_message_id`
    #
    #
    # @!attribute status
    #   Статус обработки сообщения
    #
    #   @return ['ok']
    #     если при обработке сообщения не возникло никаких ошибок
    #
    #   @return ['error']
    #     если при обработке сообщения возникла ошибка
    #
    #
    # @!attribute headers
    #   Ассоциативный массив заголовков сообщения
    #
    #   @return [Sequel::Postgres::JSONBHash]
    #     ассоциативный массив заголовков сообщения
    #
    #
    # @!attribute error_class
    #   Название класса исключения, если оно было создано во время обработки
    #   сообщения
    #
    #   @return [String]
    #     название класса исключения, если оно было создано во время обработки
    #     сообщения
    #
    #   @return [NilClass]
    #     если во время обработки сообщения не возникло никаких ошибок
    #
    #
    # @!attribute error_text
    #   Сообщение исключения, если оно было создано во время обработки
    #   сообщения
    #
    #   @return [String]
    #     сообщение исключения, если оно было создано во время обработки
    #     сообщения
    #
    #   @return [NilClass]
    #     если во время обработки сообщения не возникло никаких ошибок
    #
    class ProcessingStatus < Sequel::Model
    end
  end
end
