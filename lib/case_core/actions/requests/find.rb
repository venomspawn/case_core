# frozen_string_literal: true

require "#{$lib}/actions/base/action"

module CaseCore
  module Actions
    module Requests
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Класс действий над записями межведомственных запросов, предоставляющих
      # метод `find`, который возвращает запись междведомственного запроса,
      # найденную по предоставленным атрибутам
      #
      class Find < Base::Action
        require_relative 'find/params_schema'

        # Возвращает запись междведомственного запроса, найденную по
        # предоставленным атрибутам, или `nil`, если найти запись невозможно
        #
        # @return [CaseCore::Models::Request]
        #   найденная запись межведомственного запроса
        #
        # @return [NilClass]
        #   если запись межведомственного запроса невозможно найти по
        #   предоставленным атрибутам
        #
        def find
          find_dataset.first
        end

        private

        # Возвращает запрос Sequel на получение записей межведомственных
        # запросов
        #
        # @return [Sequel::Dataset]
        #   результирующий запрос
        #
        def find_dataset
          return Models::Request.order_by(:created_at.desc) if params.empty?

          join_request_attributes_dataset
            .select(Sequel[:requests].*)
            .where(request_attributes_conditions)
            .order_by(Sequel[:requests][:created_at].desc)
        end

        # Возвращает запрос Sequel на внутреннее соединение таблицы записей
        # межведомственных запросов и таблицы запией атрибутов межведомственных
        # запросов
        #
        # @return [Sequel::Dataset]
        #   результирующий запрос
        #
        def join_request_attributes_dataset
          Models::Request.join(:request_attributes, request_id: :id)
        end

        # Возвращает ассоциативный массив условий, по которым осуществляется
        # поиск записей межведомственных запросов
        #
        # @return [Hash]
        #   результирующий ассоциативный массив условий
        #
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
