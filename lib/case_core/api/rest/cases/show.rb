# frozen_string_literal: true

module CaseCore
  module API
    module REST
      module Cases
        # Модуль с методом REST API, который возвращает информацию о заявке
        module Show
          # Регистрация в контроллере необходимых путей
          # @param [CaseCore::API::REST::Controller] controller
          #   контроллер
          def self.registered(controller)
            # Возвращает информацию о заявке
            # @param [Hash] params
            #   ассоциативный массив, структура которого описана схемой
            #   {CaseCore::Actions::Cases::Show::PARAMS_SCHEMA}
            # @return [Status]
            #   200
            # @return [Hash]
            #   ассоциативный массив, структура которого описана схемой
            #   {CaseCore::Actions::Cases::Show::RESULT_SCHEMA}
            controller.get '/cases/:id' do
              content = Actions::Cases.show(params)
              content[:created_at] = content[:created_at].strftime('%FT%T')
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
