# frozen_string_literal: true

require "#{$lib}/version"

module CaseCore
  module API
    module REST
      # Пространство имён модуля, предоставляющего метод REST API для
      # получения информации о версии приложения
      module Version
        # Модуль с методом REST API, который возвращает информацию о версии
        # приложения
        module Show
          # Регистрация в контроллере необходимых путей
          # @param [CaseCore::API::REST::Controller] controller
          #   контроллер
          def self.registered(controller)
            # Возвращает информацию о заявке
            # @return [Status]
            #   200
            # @return [Hash]
            #   ассоциативный массив с единственным полем `version`, хранящим
            #   строку с версией приложения в качестве значения
            controller.get '/version' do
              content = Actions::Version.show(params)
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
