# encoding: utf-8

module CaseCore
  module API
    module REST
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Пространство имён методов REST API, предоставляющих действия над
      # реестрами передаваемой корреспонденции
      #
      module Registers
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Модуль с методом REST API, который возвращает список всех записей
        # реестров передаваемой корреспонденции, выбранных с помощью фильтра,
        # если таковой указан
        #
        module Index
          # Регистрация в контроллере необходимых путей
          #
          # @param [CaseCore::API::REST::Application] controller
          #   контроллер
          #
          def self.registered(controller)
            # Возвращает список всех записей реестров передаваемой
            # корреспонденции, выбранных с помощью фильтра, если таковой указан
            #
            # @param [Hash] params
            #   ассоциативный массив, структура которого описана схемой
            #   {CaseCore::Actions::Registers::Index::ParamsSchema::PARAMS_SCHEMA}
            #
            # @return [Status]
            #   200
            #
            # @return [Array]
            #   список, структура которого описана схемой
            #   {CaseCore::Actions::Registers::Index::ResultSchema::RESULT_SCHEMA}
            #
            controller.get '/registers' do
              content = registers.index(params)
              status :ok
              body Oj.dump(content)
            end
          end
        end

        Application.register Index
      end
    end
  end
end
