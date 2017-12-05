# encoding: utf-8

module CaseCore
  module API
    module REST
      module Cases
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Модуль с методом REST API, который возвращает информацию о заявке
        #
        module Show
          # Регистрация в контроллере необходимых путей
          #
          # @param [CaseCore::API::REST::Controller] controller
          #   контроллер
          #
          def self.registered(controller)
            # Возвращает информацию о заявке
            #
            # @param [Hash] params
            #   ассоциативный массив, структура которого описана схемой
            #   {CaseCore::Actions::Cases::Show::ParamsSchema::PARAMS_SCHEMA}
            #
            # @return [Status]
            #   200
            #
            # @return [Hash]
            #   ассоциативный массив, структура которого описана схемой
            #   {CaseCore::Actions::Cases::Show::ResultSchema::RESULT_SCHEMA}
            #
            controller.get '/cases/:id' do
              content = cases.show(params)
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
