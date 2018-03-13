# frozen_string_literal: true

module CaseCore
  module API
    module REST
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Пространство имён методов REST API, предоставляющих действия над
      # записями статусов обработки сообщений STOMP
      #
      module ProcessingStatuses
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Модуль с методом REST API, который возвращает информацию о статусе
        # обработки сообщения STOMP с заданным идентификатором сообщения
        # (значением заголовка `x_message_id` сообщения STOMP)
        #
        module Show
          # Регистрация в контроллере необходимых путей
          #
          # @param [CaseCore::API::REST::Controller] controller
          #   контроллер
          #
          def self.registered(controller)
            # Модуль с методом REST API, который возвращает информацию о
            # статусе обработки сообщения STOMP с заданным идентификатором
            # сообщения (значением заголовка `x_message_id` сообщения STOMP)
            #
            # @param [Hash] params
            #   ассоциативный массив, структура которого описана схемой
            #   {CaseCore::Actions::ProcessingStatuses::Show::PARAMS_SCHEMA}
            #
            # @return [Status]
            #   200
            #
            # @return [Hash]
            #   ассоциативный массив, структура которого описана схемой
            #   {CaseCore::Actions::ProcessingStatuses::Show::RESULT_SCHEMA}
            #
            controller.get '/processing_statuses/:message_id' do
              content = processing_statuses.show(params)
              status :ok
              body Oj.dump(content)
            end
          end
        end

        Controller.register Show
      end
    end
  end
end
