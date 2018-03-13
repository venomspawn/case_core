# frozen_string_literal: true

require 'json'
require 'json-schema'
require 'rest-client'
require 'sequel'

require "#{$lib}/helpers/log"

module CaseCore
  module API
    module REST
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Обработка ошибок
      #
      module Errors
        include CaseCore::Helpers::Log

        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Модуль вспомогательных методов
        #
        module Helpers
          # Возвращает объект, связанный с ошибкой
          #
          # @return [Exception]
          #   объект-исключение
          #
          def error
            env['sinatra.error']
          end

          # Возвращает сообщение об ошибке
          #
          # @return [String]
          #   сообщение об ошибке
          #
          def error_message
            need_processing = error.is_a?(RestClient::ExceptionWithResponse)
            return error.message unless need_processing
            response_message = error.response.body.to_s
            error_json_message(response_message) || response_message
          end

          # Возвращает сообщение, закодированное в JSON-формате в теле ответа,
          # или `nil`, если это невозможно
          #
          # @return [String]
          #   сообщение
          #
          # @return [NilClass]
          #   если невозможно декодировать сообщение
          #
          def error_json_message(source)
            JSON.parse(source)
          rescue JSON::ParserError
            nil
          end
        end

        # Отображение классов ошибок в коды ошибок
        #
        ERRORS_MAP = {
          ArgumentError                       => 422,
          JSON::ParserError                   => 422,
          JSON::Schema::ValidationError       => 422,
          JSON::Schema::ReadFailed            => 404,
          RestClient::BadRequest              => 400,
          RestClient::Forbidden               => 403,
          RestClient::NotFound                => 404,
          RestClient::InternalServerError     => 422,
          RestClient::Unauthorized            => 401,
          RuntimeError                        => 422,
          Sequel::DatabaseError               => 422,
          Sequel::NoMatchingRow               => 404,
          Sequel::InvalidValue                => 422,
          Sequel::UniqueConstraintViolation   => 422
        }.freeze

        # Регистрирует обработчик ошибки
        #
        # @param [CaseCore::API::REST::Controller] controller
        #   контроллер
        #
        # @param [Class] error_class
        #   класс ошибки
        #
        # @param [Integer] error_code
        #   код ошибки
        #
        def self.define_error_handler(controller, error_class, error_code)
          controller.error error_class do
            message = error_message
            log_error { <<~LOG }
              #{app_name_upcase} ERROR #{error.class} WITH MESSAGE #{message}
            LOG

            status error_code
            content = { message: message, error: error.class }
            body content.to_json
          end
        end

        # Регистрирует обработчики ошибок, классы которых определены в
        # {ERRORS_MAP}
        #
        # @param [CaseCore::API::REST::Controller] controller
        #   контроллер
        #
        def self.define_error_handlers(controller)
          ERRORS_MAP.each do |error_class, error_code|
            define_error_handler(controller, error_class, error_code)
          end
        end

        # Регистрирует обработчик ошибок, классы которых не определены в
        # {ERRORS_MAP}
        #
        # @param [CaseCore::API::REST::Controller] controller
        #   контроллер
        #
        def self.define_500_handler(controller)
          controller.error 500 do
            log_error { <<~LOG }
              #{app_name_upcase} ERROR #{error.class} WITH MESSAGE
              #{error.message} AT #{error.backtrace.first(3)}
            LOG

            status 500
            content = { message: error.message, error: error.class }
            body content.to_json
          end
        end

        # Регистрация в контроллере обработчиков ошибок
        #
        # @param [CaseCore::API::REST::Controller] controller
        #   контроллер
        #
        def self.registered(controller)
          controller.helpers Helpers
          define_error_handlers(controller)
          define_500_handler(controller)
        end
      end

      Controller.register Errors
    end
  end
end
