# frozen_string_literal: true

module CaseCore
  module API
    module REST
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Пространство имён методов REST API, предоставляющих действия над
      # записями заявок
      #
      module Cases
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Модуль с методом REST API, который возвращает список всех записей
        # заявок, выбранных с помощью фильтра, если таковой указан
        #
        module Index
          # Регистрация в контроллере необходимых путей
          #
          # @param [CaseCore::API::REST::Controller] controller
          #   контроллер
          #
          def self.registered(controller)
            # Возвращает список всех записей заявок, выбранных с помощью
            # фильра, если таковой указан
            #
            # @param [Hash] params
            #   ассоциативный массив, структура которого описана схемой
            #   {CaseCore::Actions::Cases::Index::PARAMS_SCHEMA}
            #
            # @return [Status]
            #   200
            #
            # @return [Array]
            #   список, структура которого описана схемой
            #   {CaseCore::Actions::Cases::Index::RESULT_SCHEMA}
            #
            controller.get '/cases' do
              make_integer(params, :limit, :offset)
              content = cases.index(params)
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
