# frozen_string_literal: true

module CaseCore
  module API
    module REST
      module Files
        # Модуль с методом REST API, который возвращает содержимое файла
        module Show
          # Регистрация в контроллере необходимых путей
          # @param [CaseCore::API::REST::Controller] controller
          #   контроллер
          def self.registered(controller)
            # Возвращает содержимое файла
            # @return [Status]
            #   200
            # @return [String]
            #   содержимое файла
            controller.get '/files/:id' do |id|
              content = Actions::Files.show(id: id)
              status :ok
              body content
            end
          end
        end

        Controller.register Show
      end
    end
  end
end
