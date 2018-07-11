# frozen_string_literal: true

module CaseCore
  need 'actions/base/action'

  module Actions
    module Requests
      # Класс действий над записями межведомственных запросов, предоставляющих
      # метод `find`, который возвращает запись междведомственного запроса,
      # найденную по предоставленным атрибутам
      class Find < Base::Action
        require_relative 'find/params_schema'

        # Возвращает запись междведомственного запроса, найденную по
        # предоставленным атрибутам, или `nil`, если найти запись невозможно
        # @return [CaseCore::Models::Request]
        #   найденная запись межведомственного запроса
        # @return [NilClass]
        #   если запись межведомственного запроса невозможно найти по
        #   предоставленным атрибутам
        def find
          find_dataset.first
        end

        private

        # Запрос Sequel на извлечение записей запросов
        REQUEST_DATASET = Models::Request.order_by(:created_at.desc)

        # Запрос Sequel на извлечение записей запросов, отфильтрованных по
        # значениям атрибутов
        JOIN_DATASET =
          Models::Request
          .join(:request_attributes, request_id: :id)
          .select(Sequel[:requests].*)
          .order_by(Sequel[:requests][:created_at].desc)

        # Возвращает запрос Sequel на получение записей межведомственных
        # запросов
        # @return [Sequel::Dataset]
        #   результирующий запрос
        def find_dataset
          return REQUEST_DATASET if params.empty?
          JOIN_DATASET.where(request_attributes_conditions)
        end

        # Возвращает ассоциативный массив условий, по которым осуществляется
        # поиск записей межведомственных запросов
        # @return [Hash]
        #   результирующий ассоциативный массив условий
        def request_attributes_conditions
          identifier_name = Sequel[:request_attributes]
          params.each_with_object({}) do |(name, value), memo|
            memo[identifier_name[:name]]  = name.to_s
            memo[identifier_name[:value]] = value
          end
        end
      end
    end
  end
end
