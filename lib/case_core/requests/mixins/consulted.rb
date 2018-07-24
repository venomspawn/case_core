# frozen_string_literal: true

require_relative 'url'

module CaseCore
  need 'consul/service'

  module Requests
    module Mixins
      # Модуль, предназначенный для подключения к классам, к которым уже
      # подключён модуль {CaseCore::Requests::Base::Request}. Модуль
      # предоставляет поддержку формирования URL при запросе на основе
      # информации о сервисе, к которому происходит запрос, предоставленной
      # Consul.
      module Consulted
        include URL

        private

        # Возвращает название сервиса
        # @return [#to_s]
        #   название сервиса
        def service_name
          raise "Метод `#{__method__}` не реализован"
        end

        # Возвращает информацию о сервисе, предоставленную Consul, или `nil`,
        # если при попытке получения информации произошла ошибка
        # @return [OpenStruct]
        #   информация о сервисе
        # @return [NilClass]
        #   если при попытке получения информации произошла ошибка
        def service_info
          return @service_info if defined?(@service_info)
          @service_info = Consul.service(service_name)
        rescue StandardError
          @service_info = nil
        end

        # Возвращает адрес сервера, на который происходит REST-запрос
        # @return [#to_s]
        #   адрес сервера
        def host
          result = service_info&.ServiceAddress
          return result unless result.blank?
          result = service_info&.Address
          result.blank? ? default_host : result
        end

        # Возвращает порт сервера, на который происходит REST-запрос
        # @return [#to_s]
        #   порт сервера
        def port
          result = service_info&.ServicePort
          result.blank? ? default_port : result
        end

        # Возвращает адрес сервера, на который происходит REST-запрос, по
        # умолчанию
        # @return [#to_s]
        #   адрес сервера
        def default_host
          raise "Метод `#{__method__}` не реализован"
        end

        # Возвращает порт сервера, на который происходит REST-запрос, по
        # умолчанию
        # @return [#to_s]
        #   порт сервера
        def default_port
          raise "Метод `#{__method__}` не реализован"
        end
      end
    end
  end
end
