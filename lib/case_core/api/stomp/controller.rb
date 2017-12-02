# encoding: utf-8

require 'singleton'

require "#{$lib}/settings/configurable"

require_relative 'controller/publishers'
require_relative 'controller/subscriber'

module CaseCore
  module API
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Пространство имён для STOMP API
    #
    module STOMP
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Класс контроллера STOMP API, позволяющего осуществлять публикацию
      # сообщений и подписку на сообщения
      #
      class Controller
        extend Settings::Configurable
        include Singleton

        settings_names :connection_info

        # Публикует сообщение STOMP в очереди с данным названием
        #
        # @param [#to_s] queue
        #   название очереди
        #
        # @param [#to_s] message
        #   сообщение
        #
        # @param [Hash] params
        #   параметры, передаваемые с помощью заголовков
        #
        # @raise [ArgumentError]
        #   если аргумент `params` не является объектом типа `Hash`
        #
        def self.publish(queue, message, params)
          instance.publish(queue, message, params)
        end

        # Осуществляет подписку на очередь с данным названием
        #
        # @param [#to_s] queue
        #   название очереди
        #
        # @param [Boolean] wait_for_messages
        #   следует ли переводить текущий поток в режим ожидания сообщений из
        #   очереди
        #
        # @yieldparam [Stomp::Message] message
        #   сообщение, возвращаемое STOMP-клиентом из очереди
        #
        # @return [CaseCore::API::STOMP::Controller::Subscriber]
        #   объект, осуществляющий подписку на очередь
        #
        def self.subscribe(queue, wait_for_messages = true, &block)
          instance.subscribe(queue, wait_for_messages, &block)
        end

        # Публикует сообщение STOMP в очереди с данным названием
        #
        # @param [#to_s] queue
        #   название очереди
        #
        # @param [#to_s] message
        #   сообщение
        #
        # @param [Hash] params
        #   параметры, передаваемые с помощью заголовков
        #
        # @raise [ArgumentError]
        #   если аргумент `params` не является объектом типа `Hash`
        #
        def publish(queue, message, params)
          publisher = publishers[Thread.current]
          publisher.publish(queue, message, params)
        end

        # Осуществляет подписку на очередь с данным названием
        #
        # @param [#to_s] queue
        #   название очереди
        #
        # @param [Boolean] wait_for_messages
        #   следует ли переводить текущий поток в режим ожидания сообщений из
        #   очереди
        #
        # @yieldparam [Stomp::Message] message
        #   сообщение, возвращаемое STOMP-клиентом из очереди
        #
        # @return [CaseCore::API::STOMP::Controller::Subscriber]
        #   объект, осуществляющий подписку на очередь
        #
        def subscribe(queue, wait_for_messages = true, &block)
          Subscriber.new(queue).tap do |subscriber|
            subscriber.subscribe(wait_for_messages, &block)
          end
        end

        private

        # Возвращает объект, предоставляющий доступ к объектам, публикующим
        # сообщения STOMP
        #
        # @return [CaseCore::API::STOMP::Publishers]
        #   объект, предоставляющий доступ к объектам, публикующим сообщения
        #   STOMP
        #
        def publishers
          @publishers ||= Publishers.new
        end
      end
    end
  end
end
