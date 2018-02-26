# encoding: utf-8

require "#{$lib}/version"

module CaseCore
  module API
    module REST
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Пространство имён модуля, предоставляющего метод REST API для
      # получения информации о версии приложения
      #
      module Version
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Модуль с методом REST API, который возвращает информацию о версии
        # приложения
        #
        module Show
          # Строка с телом ответа на запрос
          #
          BODY = { version: VERSION }.to_json

          # Регистрация в контроллере необходимых путей
          #
          # @param [CaseCore::API::REST::Controller] controller
          #   контроллер
          #
          def self.registered(controller)
            # Возвращает информацию о заявке
            #
            # @return [Status]
            #   200
            #
            # @return [Hash]
            #   ассоциативный массив с единственным полем `version`, хранящим
            #   строку с версией приложения в качестве значения
            #
            controller.get '/version' do
              status :ok
              body BODY
            end
          end
        end

        Controller.register Show
      end
    end
  end
end
