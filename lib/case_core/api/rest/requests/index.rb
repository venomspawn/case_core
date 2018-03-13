# frozen_string_literal: true

module CaseCore
  module API
    module REST
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Пространство имён методов REST API, предоставляющих действия над
      # записями межведомственных запросов, созданных в рамках заявок
      #
      module Requests
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Модуль с методом REST API, который возвращает список с информацией о
        # межведомственных запросах, созданных в рамках заявки
        #
        module Index
          # Регистрация в контроллере необходимых путей
          #
          # @param [CaseCore::API::REST::Controller] controller
          #   контроллер
          #
          def self.registered(controller)
            # Возвращает список с информацией о межведомственных запросах,
            # созданных в рамках заявки
            #
            # @param [Hash] params
            #   ассоциативный массив, структура которого описана схемой
            #   {CaseCore::Actions::Requests::Index::PARAMS_SCHEMA}
            #
            # @return [Status]
            #   200
            #
            # @return [Array]
            #   список, структура которого описана схемой
            #   {CaseCore::Actions::Requests::Index::RESULT_SCHEMA}
            #
            controller.get '/cases/:id/requests' do
              make_integer(params, :limit, :offset)
              content = requests.index(params)
              status :ok
              body Oj.dump(content)
            end
          end
        end

        Controller.register Index
      end
    end
  end
end
