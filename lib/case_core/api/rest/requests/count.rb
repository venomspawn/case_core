# encoding: utf-8

module CaseCore
  module API
    module REST
      module Requests
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Модуль с методом REST API, который возвращает информацию о количестве
        # межведомственных запросов, созданных в рамках заявки
        #
        module Count
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
            #   {CaseCore::Actions::Requests::Count::ParamsSchema::PARAMS_SCHEMA}
            #
            # @return [Status]
            #   200
            #
            # @return [Array]
            #   список, структура которого описана схемой
            #   {CaseCore::Actions::Requests::Count::ResultSchema::RESULT_SCHEMA}
            #
            controller.get '/cases/:id/requests_count' do
              make_integer(params, :limit, :offset)
              content = requests.count(params)
              status :ok
              body Oj.dump(content)
            end
          end
        end

        Controller.register Count
      end
    end
  end
end
