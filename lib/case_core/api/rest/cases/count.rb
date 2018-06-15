# frozen_string_literal: true

module CaseCore
  module API
    module REST
      module Cases
        # Модуль с методом REST API, который возвращает информацию о количестве
        # заявок
        module Count
          # Регистрация в контроллере необходимых путей
          # @param [CaseCore::API::REST::Controller] controller
          #   контроллер
          def self.registered(controller)
            # Возвращает информацию о количестве заявок
            # @param [Hash] params
            #   ассоциативный массив, структура которого описана схемой
            #   {CaseCore::Actions::Cases::Count::PARAMS_SCHEMA}
            # @return [Status]
            #   200
            # @return [Hash]
            #   ассоциативный массив, структура которого описана схемой
            #   {CaseCore::Actions::Cases::Count::RESULT_SCHEMA}
            controller.post '/cases_count' do
              content = cases.count(post_params)
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
