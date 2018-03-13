# frozen_string_literal: true

require_relative 'client'

module CaseCore
  module API
    module STOMP
      class Controller
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Класс объектов, публикующих сообщения STOMP
        #
        class Publisher < Client
          # Сообщение о том, что аргумент `params` должен быть объектом типа
          # `Hash`
          #
          PARAMS_NOT_A_HASH =
            'Аргумент `params` должен быть объектом типа `Hash`'

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
            raise ArgumentError, PARAMS_NOT_A_HASH unless params.is_a?(Hash)
            client.publish(queue, message, headers(params))
          end

          private

          # Префикс заголовков
          #
          HEADER_PREFIX = 'x_'

          # Возвращает правильное имя заголовка
          #
          # @param [#to_s] name
          #   исходное имя заголовка
          #
          # @return [String]
          #   результирующее имя заголовка
          #
          def header_name(name)
            header_name = name.to_s
            return header_name if header_name.start_with?(HEADER_PREFIX)
            "#{HEADER_PREFIX}#{header_name}"
          end

          # Возвращает ассоциативный массив заголовков сообщения
          #
          # @param [Hash] params
          #   параметры, передаваемые через заголовки
          #
          # @return [Hash]
          #   результирующий ассоциативный массив
          #
          def headers(params)
            params.each_with_object({}) do |(name, value), memo|
              key = header_name(name)
              memo[key] = value
            end
          end
        end
      end
    end
  end
end
