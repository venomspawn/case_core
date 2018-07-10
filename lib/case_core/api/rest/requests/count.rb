# frozen_string_literal: true

module CaseCore
  module API
    module REST
      module Requests
        # Модуль с методом REST API, который возвращает информацию о количестве
        # межведомственных запросов, созданных в рамках заявки
        module Count
          # Регистрация в контроллере необходимых путей
          # @param [CaseCore::API::REST::Controller] controller
          #   контроллер
          def self.registered(controller)
            # Возвращает список с информацией о межведомственных запросах,
            # созданных в рамках заявки
            # @param [Hash] params
            #   ассоциативный массив, структура которого описана схемой
            #   {CaseCore::Actions::Requests::Count::PARAMS_SCHEMA}
            # @return [Status]
            #   200
            # @return [Array]
            #   список, структура которого описана схемой
            #   {CaseCore::Actions::Requests::Count::RESULT_SCHEMA}
            controller.post '/cases/:id/requests_count' do |id|
              content = Actions::Requests.count(request.body, id: id)
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
