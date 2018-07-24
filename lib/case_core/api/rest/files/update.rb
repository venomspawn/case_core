# frozen_string_literal: true

module CaseCore
  module API
    module REST
      module Files
        # Модуль с методом REST API, который обновляет содержимое файла
        module Update
          # Регистрация в контроллере необходимых путей
          # @param [CaseCore::API::REST::Controller] controller
          #   контроллер
          def self.registered(controller)
            # Обновляет содержимое файла
            # @return [Status]
            #   204
            controller.put '/files/:id' do |id|
              Actions::Files.update(id: id, content: request.body)
              status :no_content
            end
          end
        end

        Controller.register Update
      end
    end
  end
end
