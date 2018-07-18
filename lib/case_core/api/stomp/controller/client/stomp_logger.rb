# frozen_string_literal: true

require 'stomp/null_logger'

module CaseCore
  need 'helpers/log'

  module API
    module STOMP
      class Controller
        class Client
          # Класс журнала событий STOMP
          class StompLogger < Stomp::NullLogger
            include Helpers::Log

            # Создаёт запись в журнале событий о том, что STOMP-клиент
            # подключён к серверу очередей
            # @param [Hash] parms
            #   параметры подключения
            def on_connected(parms)
              log_info { <<-LOG }
                Connected to #{parms[:cur_host]}:#{parms[:cur_port]}
              LOG
            end

            # Создёт запись в журнале событий о том, что STOMP-клиент
            # подписался на очередь
            # @param [Hash] _parms
            #   параметры подключения
            # @param [Hash] headers
            #   заголовки
            def on_subscribe(_parms, headers)
              log_info { "Subscribed to `#{headers[:destination]}`" }
            end

            # Создаёт запись в журнале событий о том, что STOMP-клиент получил
            # сообщение
            # @param [Hash] parms
            #   параметры подключения
            # @param [Object] result
            #   сообщение
            def on_receive(parms, result)
              log_debug { <<-LOG }
                Recieved result `#{repaired_string(result.body)}` with params
                `#{parms}`
              LOG
            end

            # Создаёт запись в журнале событий о том, что Stomp-клиент
            # опубликовал сообщение в очередь
            # @param [Hash] parms
            #   параметры подключения
            # @param [Object] message
            #   сообщение
            # @param [Hash] headers
            #   заголовки
            def on_publish(parms, message, headers)
              log_debug { <<-LOG }
                Published message `#{repaired_string(message)}` with headers
                `#{headers}` and params `#{parms}`
              LOG
            end
          end
        end
      end
    end
  end
end
