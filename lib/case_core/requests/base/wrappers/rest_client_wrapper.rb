# frozen_string_literal: true

require 'rest-client'

require_relative 'rest_client_wrapper/helpers'

module CaseCore
  module Requests
    module Base
      # Пространство имён для классов оболочек над библиотеками, выполняющих
      # запросы ко внешним ресурсам
      module Wrappers
        # Класс оболочки над библиотекой `rest-client`
        class RestClientWrapper
          include Helpers

          # Выполняет REST-запрос, производя журналирование
          # @param [Hash] request_params
          #   параметры запроса
          # @return [RestClient::Response]
          #   полученный ответ
          def self.execute_request(request_params)
            new(request_params).execute_request
          end

          # Инициализирует объект класса
          # @param [Hash] request_params
          #   параметры запроса
          def initialize(request_params)
            @request_params = request_params
          end

          # Выполняет REST-запрос, производя журналирование
          # @return [RestClient::Response]
          #   полученный ответ
          def execute_request
            log_request(binding)
            response = RestClient::Request.execute(request_params)
            response.tap { log_request_response(binding, response) }
          rescue StandardError => e
            log_request_error(binding, e)
            raise e
          end

          private :logger, :log_with_level, :log_info, :log_debug, :log_error

          private

          # Параметры запроса
          # @return [Hash]
          #   параметры запроса
          attr_reader :request_params
        end
      end
    end
  end
end
