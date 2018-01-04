# encoding: utf-8

module MSPCase
  module EventProcessors
    class RespondingSTOMPMessageProcessor
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Модуль, предоставляющий пространства имён исключений, создаваемых
      # содержащим классом
      #
      module Errors
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Пространство имён исключений, связанных с записью заявки
        #
        module Case
          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Класс исключений, сигнализирующих о том, что запись заявки,
          # ассоциированной с записью запроса, имеет значение поля `type`,
          # которое не равно `msp_case`
          #
          class BadType < RuntimeError
            # Инциализирует объект класса
            #
            # @param [CaseCore::Models::Case] c4s3
            #   запись заявки
            #
            def initialize(c4s3)
              super(<<-MESSAGE.squish)
                Заявка с идентификатором записи `#{c4s3.id}` имеет неверное
                значение поля `type`
              MESSAGE
            end
          end

          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Класс исключений, сигнализирующих о том, что значение атрибута
          # `status` заявки не является допустимым
          #
          class BadStatus < RuntimeError
            # Инициализирует объект класса
            #
            # @param [CaseCore::Models::Case] c4s3
            #   запись заявки
            #
            # @param [#to_s] status
            #   статус заявки
            #
            def initialize(c4s3, status)
              super(<<-MESSAGE.squish)
                Статус `#{status}` заявки с идентификатором записи `#{c4s3.id}`
                не равен `processing`
              MESSAGE
            end
          end
        end

        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Пространство имён исключений, связанных с аргументом `message`
        # конструктора содержащего класса
        #
        module Message
          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Класс исключений, сигнализирующих о том, что аргумент `message`
          # конструктора содержащего класса не является объектом класса
          # `Stomp::Message`
          #
          class BadType < ArgumentError
            # Инциализирует объект класса
            #
            def initialize
              super(<<-MESSAGE.squish)
                Аргумент `message` не является объектом класса `Stomp::Message`
              MESSAGE
            end
          end
        end

        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Пространство имён исключений, связанных с записями запросов
        #
        module Request
          # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
          #
          # Класс исключений, сигнализирующих о том, что запись запроса не была
          # найдена по идентификатору исходного сообщения STOMP
          #
          class NotFound < RuntimeError
            # Инциализирует объект класса
            #
            # @param [#to_s] original_message_id
            #   идентификатор исходного сообщения STOMP
            #
            def initialize(original_message_id)
              super(<<-MESSAGE.squish)
                Запись межведомственного запроса не была найдена по
                идентификатору `#{original_message_id}` исходного сообщения
                STOMP
              MESSAGE
            end
          end
        end
      end
    end
  end
end
