# frozen_string_literal: true

require_relative 'response/helpers'

module CaseCore
  module API
    module STOMP
      class Controller
        module Processors
          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Класс обработчиков ответных сообщений STOMP
          #
          class Response
            include Helpers

            # Осуществляет обработку данного сообщения STOMP
            #
            # @param [Stomp::Message] message
            #   сообщение STOMP
            #
            # @raise [ArgumentError]
            #   если аргумент не является объектом типа `Stomp::Message`
            #
            # @return [Boolean]
            #   была ли обработка успешной
            #
            def self.process(message)
              new(message).process
            end

            # Инициализирует объект класса
            #
            # @param [Stomp::Message] message
            #   сообщение STOMP
            #
            # @raise [ArgumentError]
            #   если аргумент не является объектом типа `Stomp::Message`
            #
            def initialize(message)
              check_message!(message)
              @message = message
            end

            # Осуществляет обработку данного сообщения STOMP
            #
            # @return [Boolean]
            #   была ли обработка успешной
            #
            def process
              processor = loaded_logics.find(&method(:process_logic))
              processor.is_a?(Module).tap do |result|
                if result
                  log_processor(processor, message, binding)
                else
                  log_no_processor(loaded_logics, message, binding)
                end
              end
            end

            private

            # Сообщение STOMP
            #
            # @return [Stomp::Message]
            #   сообщение STOMP
            #
            attr_reader :message

            # Название функции, которая обрабатывает STOMP-сообщения
            #
            HANDLER_NAME = :on_responding_stomp_message

            # Возвращает список загруженных модулей бизнес-логики
            #
            # @return [Array]
            #   список загруженных модулей бизнес-логики
            #
            def loaded_logics
              @loaded_logics ||= Logic::Loader.loaded_logics
            end

            # Вызывает функцию обработки STOMP-сообщений у модуля
            # бизнес-логики, если она присутствует, и возвращает результат
            # работы этой функции. Возвращает `nil`, если функция отсутствует
            # в модуле.
            #
            # @param [Module] logic
            #   модуль бизнес-логики
            #
            # @return [Object]
            #   результат работы функции обработки STOMP-сообщения
            #
            # @return [NilClass]
            #   если функция отсутствует в модуле бизнес-логики
            #
            def process_logic(logic)
              return process_handler(logic) if logic.respond_to?(HANDLER_NAME)
              log_no_handler(logic, HANDLER_NAME, binding)
            end

            # Вызывает функцию обработки STOMP-сообщений о модуля бизнес-логики
            # и возвращает результат её работы. В случае возникновения ошибок
            # возвращает `nil`.
            #
            # @param [Module] logic
            #   модуль бизнес-логики
            #
            # @return [Object]
            #   результат работы функции обработки STOMP-сообщения
            #
            # @return [NilClass]
            #   если во время вызова функции возникла ошибка
            #
            def process_handler(logic)
              result, e = safe_call(logic, HANDLER_NAME, message)
              if e.nil?
                log_cant_process(logic, message, binding) unless result
              else
                log_handler_error(e, logic, HANDLER_NAME, message, binding)
              end
              result
            end
          end
        end
      end
    end
  end
end
