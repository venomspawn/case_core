# frozen_string_literal: true

module CaseCore
  module API
    module REST
      # Пространство имён модуля, предоставляющего методы REST API для
      # оперирования файлами
      module Files
        # Модуль с методом REST API, который создаёт запись файла
        module Create
          # Регистрация в контроллере необходимых путей
          # @param [CaseCore::API::REST::Controller] controller
          #   контроллер
          def self.registered(controller)
            # Создаёт запись файла с телом запроса в качестве содержимого и
            # возвращает информацию о созданной записи
            # @return [Status]
            #   201
            # @return [Hash]
            #   ассоциативный массив, структура которого описана JSON-схемой
            #   {CaseCore::Actions::Files::Create::RESULT_SCHEMA}
            controller.post '/files' do
              content = Actions::Files.create(request.body)
              status :created
              body Oj.dump(content)
            end
          end
        end

        Controller.register Create
      end
    end
  end
end
