# encoding: utf-8

require_relative 'client'

module CaseCore
  module API
    module STOMP
      class Controller
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Класс объектов, осуществляющих подписку на сообщения STOMP
        #
        class Subscriber < Client
          # Сообщение о том, что методу не предоставлен блок
          #
          BLOCK_IS_ABSENT = 'Методу не предоставлен блок'

          # Инициализирует объект класса
          #
          # @param [#to_s] queue
          #   название очереди
          #
          def initialize(queue)
            @queue = queue
          end

          # Осуществляет подписку на сообщения STOMP очереди с предоставленным
          # названием
          #
          # @param [Boolean] wait_for_messages
          #   следует ли переводить текущий поток в режим ожидания сообщений из
          #   очереди
          #
          # @yieldparam [Stomp::Message] message
          #   сообщение, возвращаемое Stomp-клиентом из очереди
          #
          # @raise [ArgumentError]
          #   если методу не предоставлен блок
          #
          def subscribe(wait_for_messages = true)
            raise ArgumentError, BLOCK_IS_ABSENT unless block_given?
            client.subscribe(queue.to_s) { |message| yield message }
            join if wait_for_messages
          end

          # Отменяет подписку на сообщения STOMP
          #
          def unsubscribe
            client.unsubscribe(queue.to_s)
          end

          private

          # Название очереди
          #
          # @return [#to_s]
          #   название очереди
          #
          attr_reader :queue

          # Переводит выполнение в режим ожидания сообщений из очереди
          #
          def join
            client.join
            client.close
          end
        end
      end
    end
  end
end
