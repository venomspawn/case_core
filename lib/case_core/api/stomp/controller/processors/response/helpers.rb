# encoding: utf-8

require "#{$lib}/helpers/log"

module CaseCore
  module API
    module STOMP
      class Controller
        module Processors
          class Response
            # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
            #
            # Вспомогательный модуль, предназначенный для включения содержащим
            # класом
            #
            module Helpers
              include CaseCore::Helpers::Log

              # Сообщение о том, что аргумент `message` не является объектом
              # типа `Stomp::Message`
              #
              WRONG_MESSAGE_TYPE =
                'Аргумент `message` не является объектом типа `Stomp::Message`'

              # Проверяет, что аргумент является объектом типа `Stomp::Message`
              #
              # @param [Object] message
              #   аргумент
              #
              # @raise [ArgumentError]
              #   если аргумент не является объектом типа `Stomp::Message`
              #
              def check_message!(message)
                return if message.is_a?(Stomp::Message)
                raise ArgumentError, WRONG_MESSAGE_TYPE
              end

              # Создаёт новую запись в журнале событий о том, что
              # STOMP-сообщение обработано данным модулем бизнес-логики
              #
              # @param [Module] logic
              #   модуль бизнес-логики
              #
              # @param [Stomp::Message] message
              #   объект с информацией о STOMP-сообщении
              #
              # @param [Binding] context
              #   контекст
              #
              def log_processor(logic, message, context)
                log_info(context) { <<-LOG }
                  Модуль бизнес-логики `#{logic}` обработал STOMP-сообщение со
                  следующими заголовками: `#{message.headers}`
                LOG
              end

              # Создаёт новую запись в журнале событий о том, что для
              # STOMP-сообщения с данными заголовками не нашлось обработчика
              # среди загруженных модулей бизнес-логики
              #
              # @param [Array] loaded_logics
              #   список загруженных модулей бизнес-логики
              #
              # @param [Stomp::Message] message
              #   объект с информацией о STOMP-сообщении
              #
              # @param [Binding] context
              #   контекст
              #
              def log_no_processor(loaded_logics, message, context)
                log_warn(context) { loaded_logics.empty? ? <<-EMPTY : <<-LOG }
                  Нет загруженных модулей бизнес-логики
                EMPTY
                  Среди загруженных модулей бизнес-логики
                  (#{loaded_logics.join('`, `')}) не нашлось обработчика
                  STOMP-сообщения со следующими заголовками:
                  `#{message.headers}`
                LOG
              end

              # Создаёт новую запись в журнале событий о том, что у модуля
              # бизнес-логики не нашлось функции с данным именем
              #
              # @param [Module] logic
              #   модуль бизнес-логики
              #
              # @param [#to_s] handler_name
              #   название функции
              #
              # @param [Binding] context
              #   контекст
              #
              def log_no_handler(logic, handler_name, context)
                log_debug(context) { <<-LOG }
                  У модуля бизнес-логики `#{logic}` нет функции с названием
                  `#{handler_name}`
                LOG
              end

              # Создаёт новую запись в журнале событий о том, что модуль
              # бизнес-логики не стал обрабатывать STOMP-сообщение
              #
              # @param [Module] logic
              #   модуль бизнес-логики
              #
              # @param [Stomp::Message] message
              #   объект с информацией о STOMP-сообщении
              #
              # @param [Binding] context
              #   контекст
              #
              def log_cant_process(logic, message, context)
                log_debug(context) { <<-LOG }
                  Модуль бизнес-логики `#{logic}` не стал обрабатывать
                  STOMP-сообщение со следующими заголовками:
                  `#{message.headers}`
                LOG
              end

              # Создаёт новую запись в журнале событий о том, что при вызове
              # функции обработки STOMP-сообщения у модуля бизнес-логики
              # произошла ошибка
              #
              # @param [Exception] e
              #   объект с информацией об ошибке
              #
              # @param [Module] logic
              #   модуль бизнес-логики
              #
              # @param [#to_s] handler_name
              #   название функции
              #
              # @param [Stomp::Message] message
              #   объект с информацией о STOMP-сообщении
              #
              # @param [Binding] context
              #   контекст
              #
              def log_handler_error(e, logic, handler_name, message, context)
                log_error(context) { <<-LOG }
                  При вызове функции `#{handler_name}` модуля бизнес-логики
                  `#{logic}` для обработки STOMP-сообщения с заголовками
                  `#{message.headers}` произошла ошибка `#{e.class}`:
                  `#{e.message}`
                LOG
              end
            end
          end
        end
      end
    end
  end
end
