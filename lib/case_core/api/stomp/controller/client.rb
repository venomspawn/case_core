# encoding: utf-8

require 'stomp'

require_relative 'client/stomp_logger'

module CaseCore
  module API
    module STOMP
      class Controller
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Класс объектов, являющихся обёрткой над объектом класса
        # `Stomp::Client`
        #
        class Client
          private

          # Возвращает объект STOMP-клиента
          #
          # @return [Stomp::Client]
          #   объект STOMP-клиента
          #
          def client
            @client ||= Stomp::Client.new(client_params)
          end

          # Возвращает ассоциативный массив параметров STOMP-клиента
          #
          # @return [Hash]
          #   ассоциативный массив параметров STOMP-клиента
          #
          def client_params
            connection_info.merge(logger: StompLogger.new)
          end

          # Возвращает ассоциативный массив параметров соединения
          # STOMP-клиента
          #
          # @return [Hash]
          #   ассоциативный массив параметров соединения STOMP-клиента
          #
          def connection_info
            Controller.settings.connection_info
          end
        end
      end
    end
  end
end
