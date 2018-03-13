# frozen_string_literal: true

require 'rest-client'

require_relative 'rest_client_wrapper/helpers'

module CaseCore
  module Requests
    module Base
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Пространство имён для классов оболочек над библиотеками, выполняющих
      # запросы ко внешним ресурсам
      #
      module Wrappers
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Класс оболочки над библиотекой `rest-client`
        #
        class RestClientWrapper
          include Helpers

          # Выполняет REST-запрос, производя журналирование
          #
          # @param [Hash] request_params
          #   параметры запроса
          #
          # @return [RestClient::Response]
          #   полученный ответ
          #
          def self.execute_request(request_params)
            new(request_params).execute_request
          end

          # Инициализирует объект класса
          #
          # @param [Hash] request_params
          #   параметры запроса
          #
          def initialize(request_params)
            @request_params = request_params
          end

          # Выполняет REST-запрос, производя журналирование
          #
          # @return [RestClient::Response]
          #   полученный ответ
          #
          def execute_request
            log_request(binding)
            response = RestClient::Request.execute(request_params)
            response.tap { log_request_response(binding, response) }
          rescue StandardError => e
            log_request_error(binding, e)
            raise e
          end

          private :logger
          private :log_with_level
          private :log_info
          private :log_debug
          private :log_error

          private

          # Параметры запроса
          #
          # @return [Hash]
          #   параметры запроса
          #
          attr_reader :request_params
        end
      end
    end
  end
end
