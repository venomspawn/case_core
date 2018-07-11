# frozen_string_literal: true

CaseCore.need 1

module CaseCore
  module API
    module STOMP
      class Controller
        # Пространство имён классов обработчиков сообщений STOMP
        module Processors
          # Класс обработчиков сообщений STOMP, вызывающих действия
          class Incoming
            include Helpers::Log

            # Осуществляет разбор данного сообщения STOMP
            # @param [Stomp::Message] message
            #   сообщение STOMP
            # @raise [ArgumentError]
            #   если аргумент не является объектом типа `Stomp::Message`
            # @return [Boolean]
            #   был ли разбор успешным
            def self.process(message)
              new(message).process
            end

            # Инициализирует объект класса
            # @param [Stomp::Message] message
            #   сообщение STOMP
            # @raise [ArgumentError]
            #   если аргумент не является объектом типа `Stomp::Message`
            def initialize(message)
              check_message!(message)
              @message = message
            end

            # Осуществляет разбор сообщения STOMP.
            #
            # 1.  Разбор начинается с изучения заголовка `x_message_id`.
            #     Значение в этом заголовке интерпретируется в качестве
            #     идентификатора сообщения. При отсутствии этого заголовка
            #     разбор останавливается с созданием соответствующего
            #     исключения.
            # 2.  Значение заголовка `x_entities` интерпретируется в качестве
            #     названия модуля пространства имён `CaseCore::Actions`
            #     (значение предварительно приводится к форме множественного
            #     числа и ВерблюжьемуРегистру). При отсутствии этого заголовка
            #     разбор останавливается с созданием соответствующего
            #     исключения.
            # 3.  Значение заголовка `x_action` интерпретируется в качестве
            #     названия функции модуля, найденного во время этапа 2
            #     (значение предварительно приводится к змеиному_регистру). При
            #     отсутствии этого заголовка разбор останавливается с созданием
            #     соответствующего исключения.
            # 4.  Тело сообщения интерпретируется как JSON-строка. Если тело
            #     сообщения не является корректной JSON-строкой, то разбор
            #     останавливается с созданием соответствующего исключения.
            # 5.  После разбора заголовков в модуле с названием, найденным во
            #     время этапа 2, вызывается функция с названием, найденным во
            #     время этапа 3, и аргументом, восстановленным из тела
            #     сообщения во время этапа 4.
            #     *   Если во время процесса разбора и вызова функции создаётся
            #         исключение, то соответствующая информация выводится в
            #         журнал событий, а также создаётся запись в таблице
            #         `processing_statuses` со значением поля `status`, равным
            #         `error`.
            #     *   Если исключение не возникает, то создаётся запись в
            #         таблице `processing_statuses` со значением поля `status`,
            #         равным `ok`.
            #     В обоих случаях в записи сохраняются заголовки сообщения
            #     вместе со значением заголовка `x_message_id` (или с `nil`,
            #     если это значение отсутствует).
            # @return [Boolean]
            #   был ли разбор успешным
            def process
              message_id = message_id!
              module!.send(action!, body!)
              create_ok_processing_status

              true
            rescue StandardError => err
              log_processing_error(err, binding)
              create_error_processing_status(err)

              false
            end

            private

            # Сообщение STOMP
            # @return [Stomp::Message]
            #   сообщение STOMP
            attr_reader :message

            # Сообщение о том, что аргумент `message` не является объектом типа
            # `Stomp::Message`
            WRONG_MESSAGE_TYPE =
              'Аргумент `message` не является объектом типа `Stomp::Message`'

            # Проверяет, что аргумент является объектом типа `Stomp::Message`
            # @param [Object] message
            #   аргумент
            # @raise [ArgumentError]
            #   если аргумент не является объектом типа `Stomp::Message`
            def check_message!(message)
              return if message.is_a?(Stomp::Message)
              raise ArgumentError, WRONG_MESSAGE_TYPE
            end

            # Возвращает объект, чьё JSON-представление хранится в теле
            # сообщения STOMP
            # @return [Object]
            #   результирующий объект
            # @raise [Oj::ParseError, EncodingError]
            #   если тело сообщения не является корректной JSON-строкой
            def body!
              Oj.load(message.body)
            end

            # Возвращает ассоциативный массив заголовков сообщения STOMP
            # @return [Hash]
            #   ассоциативный массив заголовков сообщения STOMP
            def headers
              @headers ||= message.headers
            end

            # Возвращает значение заголовка `x_message_id`
            # @return [String]
            #   значение заголовка `x_message_id`
            # @return [NilClass]
            #   если значение заголовка `x_message_id` отсутствует
            def message_id
              headers['x_message_id']
            end

            # Сообщение о том, что у сообщения STOMP отсутствует заголовок
            # `x_message_id`
            ABSENT_HEADER_X_MESSAGE_ID =
              'У сообщения STOMP отсутствует заголовок `x_message_id`'

            # Возвращает значение заголовка `x_message_id`
            # @return [String]
            #   значение заголовка `x_message_id`
            # @raise [RuntimeError]
            #   если значение заголовка `x_message_id` отсутствует
            def message_id!
              message_id || (raise ABSENT_HEADER_X_MESSAGE_ID)
            end

            # Возвращает значение заголовка `x_entities`
            # @return [String]
            #   значение заголовка `x_entities`
            # @return [NilClass]
            #   если значение заголовка `x_entities` отсутствует
            def entities
              headers['x_entities']
            end

            # Сообщение о том, что у сообщения STOMP отсутствует заголовок
            # `x_entities`
            ABSENT_HEADER_X_ENTITIES =
              'У сообщения STOMP отсутствует заголовок `x_entities`'

            # Возвращает значение заголовка `x_entities`
            # @return [String]
            #   значение заголовка `x_entities`
            # @raise [RuntimeError]
            #   если значение заголовка `x_entities` отсутствует
            def entities!
              entities || (raise ABSENT_HEADER_X_ENTITIES)
            end

            # Возвращает значение заголовка `x_action`
            # @return [String]
            #   значение заголовка `x_action`
            # @return [NilClass]
            #   если значение заголовка `x_action` отсутствует
            def action
              headers['x_action']
            end

            # Сообщение о том, что у сообщения STOMP отсутствует заголовок
            # `x_action`
            ABSENT_HEADER_X_ACTION =
              'У сообщения STOMP отсутствует заголовок `x_action`'

            # Возвращает значение заголовка `x_action`
            # @return [String]
            #   значение заголовка `x_action`
            # @raise [RuntimeError]
            #   если значение заголовка `x_action` отсутствует
            def action!
              action || (raise ABSENT_HEADER_X_ACTION)
            end

            # Возвращает модуль пространства имён {CaseCore::Actions} по
            # названию, возвращаемому методом {entities!}
            # @return [Module]
            #   результирующий модуль
            # @raise [RuntimeError]
            #   если значение заголовка `x_entities` отсутствует
            # @raise [NameError]
            #   если не найдено пространство имён {CaseCore::Actions}
            # @raise [NameError]
            #   если модуль не найден по названию
            def module!
              module_name = entities!.pluralize.camelize
              namespace = CaseCore.const_get(:Actions)
              namespace.const_get(module_name)
            end

            # Создаёт запись модели {CaseCore::Models::ProcessingStatus} со
            # значением `ok` поля `status`
            def create_ok_processing_status
              Models::ProcessingStatus
                .create(message_id: message_id, status: :ok, headers: headers)
            end

            # Создаёт запись модели {CaseCore::Models::ProcessingStatus} со
            # значением `error` поля `status`
            # @param [Exception] err
            #   объект с информацией об ошибке
            def create_error_processing_status(err)
              Models::ProcessingStatus.create(
                message_id:  message_id,
                status:      :error,
                headers:     headers,
                error_class: err.class,
                error_text:  err.message
              )
            end

            # Создаёт запись в журнале событий о том, что во время обработки
            # сообщения STOMP произошла ошибка
            # @param [Exception] err
            #   объект с информацией об ошибке
            # @param [Binding] context
            #   контекст
            def log_processing_error(err, context)
              log_error(context) { <<-LOG }
                Во время обработки сообщения STOMP с заголовками `#{headers}`
                произошла ошибка `#{err.class}`: `#{err.message}`
              LOG
            end
          end
        end
      end
    end
  end
end
