# frozen_string_literal: true

module CaseCore
  module API
    module REST
      # Пространство имён методов REST API, предоставляющих действия над
      # записями документов, прикреплённых к записи заявки
      module Documents
        # Модуль с методом REST API, который возвращает список с информацией о
        # документах, прикреплённых к заявке
        module Index
          # Регистрация в контроллере необходимых путей
          # @param [CaseCore::API::REST::Controller] controller
          #   контроллер
          def self.registered(controller)
            # Возвращает список с информацией о документах, прикреплённых к
            # заявке
            # @param [Hash] params
            #   ассоциативный массив, структура которого описана схемой
            #   {CaseCore::Actions::Documents::Index::PARAMS_SCHEMA}
            # @return [Status]
            #   200
            # @return [Array]
            #   список, структура которого описана схемой
            #   {CaseCore::Actions::Documents::Index::RESULT_SCHEMA}
            controller.get '/cases/:id/documents' do
              content = Actions::Documents.index(params)
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
