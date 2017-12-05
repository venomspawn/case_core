# encoding: utf-8

module CaseCore
  module API
    module STOMP
      class Controller
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Вспомогательный модуль, подключаемый к тестам класса
        # {CaseCore::API::STOMP::Controller::Processor}
        #
        module ProcessorSpecHelper
          # Создаёт ассоциативный массив заголовков сообщения STOMP на основе
          # предоставленных значений, пропуская значения, равные `nil`
          #
          # @return [Hash]
          #   результирующий ассоциативный массив заголовков сообщения STOMP
          #
          def create_headers(message_id, entities, action)
            hash = {
              'x_message_id' => message_id,
              'x_entities'   => entities,
              'x_action'     => action
            }
            hash.compact
          end
        end
      end
    end
  end
end
