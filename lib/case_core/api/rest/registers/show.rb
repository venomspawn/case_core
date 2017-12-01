# encoding: utf-8

module CaseCore
  module API
    module REST
      module Registers
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Модуль с методом REST API, который возвращает информацию о реестре
        # передаваемой корреспонденции с заданным идентификатором записи
        #
        module Show
          # Регистрация в контроллере необходимых путей
          #
          # @param [CaseCore::API::REST::Controller] controller
          #   контроллер
          #
          def self.registered(controller)
            # Возвращает ассоциативный массив с информацией о реестре
            # передаваемой корреспонденции с заданным идентификатором записи
            #
            # @param [Hash] params
            #   ассоциативный массив, структура которого описана схемой
            #   {CaseCore::Actions::Registers::Show::ParamsSchema::PARAMS_SCHEMA}
            #
            # @return [Status]
            #   200
            #
            # @return [Hash]
            #   ассоциативный массив, структура которого описана схемой
            #   {CaseCore::Actions::Registers::Show::ResultSchema::RESULT_SCHEMA}
            #
            controller.get '/registers/:id' do
              content = registers.show(params)
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
