# frozen_string_literal: true

require 'singleton'
require 'stomp'

require "#{$lib}/settings/configurable"

require_relative 'controller/processors/incoming'
require_relative 'controller/processors/response'
require_relative 'controller/publishers'
require_relative 'controller/subscriber'

module CaseCore
  module API
    # Пространство имён для STOMP API
    module STOMP
      # Класс контроллера STOMP API, позволяющего осуществлять публикацию
      # сообщений и подписку на сообщения
      class Controller
        extend Settings::Configurable
        include Singleton

        settings_names :connection_info, :incoming_queue, :response_queues
        settings_names :incoming_listeners, :response_listeners

        # Публикует сообщение STOMP в очереди с данным названием
        # @param [#to_s] queue
        #   название очереди
        # @param [#to_s] message
        #   сообщение
        # @param [Hash] params
        #   параметры, передаваемые с помощью заголовков
        # @raise [ArgumentError]
        #   если аргумент `params` не является объектом типа `Hash`
        def self.publish(queue, message, params)
          instance.publish(queue, message, params)
        end

        # Осуществляет подписку на очередь с данным названием
        # @param [#to_s] queue
        #   название очереди
        # @param [Boolean] wait_for_messages
        #   следует ли переводить текущий поток в режим ожидания сообщений из
        #   очереди
        # @yieldparam [Stomp::Message] message
        #   сообщение, возвращаемое STOMP-клиентом из очереди
        # @return [CaseCore::API::STOMP::Controller::Subscriber]
        #   объект, осуществляющий подписку на очередь
        # @raise [ArgumentError]
        #   если методу не предоставлен блок
        def self.subscribe(queue, wait_for_messages = true, &block)
          instance.subscribe(queue, wait_for_messages, &block)
        end

        # Подписывается на основную очередь, название которой задаётся с
        # помощью настройки `incoming_queue`, и осуществляет разбор входящих
        # сообщений согласно API
        def self.run!
          instance.run!
        end

        # Публикует сообщение STOMP в очереди с данным названием
        # @param [#to_s] queue
        #   название очереди
        # @param [#to_s] message
        #   сообщение
        # @param [Hash] params
        #   параметры, передаваемые с помощью заголовков
        # @raise [ArgumentError]
        #   если аргумент `params` не является объектом типа `Hash`
        def publish(queue, message, params)
          publisher = publishers[Thread.current]
          publisher.publish(queue, message, params)
        end

        # Осуществляет подписку на очередь с данным названием
        # @param [#to_s] queue
        #   название очереди
        # @param [Boolean] wait_for_messages
        #   следует ли переводить текущий поток в режим ожидания сообщений из
        #   очереди
        # @yieldparam [Stomp::Message] message
        #   сообщение, возвращаемое STOMP-клиентом из очереди
        # @return [CaseCore::API::STOMP::Controller::Subscriber]
        #   объект, осуществляющий подписку на очередь
        # @raise [ArgumentError]
        #   если методу не предоставлен блок
        def subscribe(queue, wait_for_messages = true, &block)
          Subscriber.new(queue).tap do |subscriber|
            subscriber.subscribe(wait_for_messages, &block)
          end
        end

        # Подписывается на очереди сообщений, заданные настройками контроллера,
        # устанавливает обработку сигналов прекращения работы приложения, после
        # чего останавливает текущий поток выполнения
        def run!
          subscribe_on_incoming
          subscribe_on_responses
          setup_traps
          sleep
        end

        private

        # Возвращает объект, предоставляющий доступ к объектам, публикующим
        # сообщения STOMP
        # @return [CaseCore::API::STOMP::Publishers]
        #   объект, предоставляющий доступ к объектам, публикующим сообщения
        #   STOMP
        def publishers
          @publishers ||= Publishers.new
        end

        # Осуществляет подписку на очередь сообщений, после разбора которых
        # осуществляется вызов действий
        def subscribe_on_incoming
          incoming_queue = Controller.settings.incoming_queue
          listeners = Controller.settings.incoming_listeners
          block = Processors::Incoming.method(:process)
          listeners.times { subscribe(incoming_queue, false, &block) }
        end

        # Осуществляет подписку на очереди ответных сообщений
        def subscribe_on_responses
          response_queues = Controller.settings.response_queues
          listeners = Controller.settings.response_listeners
          block = Processors::Response.method(:process)
          listeners.times do
            response_queues.each do |response_queue|
              subscribe(response_queue, false, &block)
            end
          end
        end

        # Названия обрабатываемых сигналов
        SIGNALS = %w[INT TERM].freeze

        # Устанавливает обработку входящих сигналов
        def setup_traps
          SIGNALS.each do |signal|
            previous_handler = trap(signal) do
              Thread.exit
              previous_handler.call
            end
          end
        end
      end
    end
  end
end
