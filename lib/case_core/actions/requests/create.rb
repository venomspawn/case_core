# frozen_string_literal: true

require 'securerandom'

require "#{$lib}/actions/base/action"
require "#{$lib}/actions/base/mixins/transactional"

module CaseCore
  module Actions
    module Requests
      # Класс действий над записями межведомственных запросов, предоставляющих
      # метод `create`, который создаёт новую запись межведомственного запроса
      # вместе с записями его атрибутов
      class Create < Base::Action
        require_relative 'create/params_schema'

        include Base::Mixins::Transactional

        # Создаёт новую запись межведомственного запроса вместе с записями его
        # атрибутов и возвращает её
        # @return [CaseCore::Models::Request]
        #   созданная запись межведомственного запроса
        def create
          transaction do
            Models::Request.create(request_attrs).tap(&method(:create_attrs))
          end
        end

        private

        # Создаёт и возвращает ассоциативный массив атрибутов записи
        # межведомственного запроса на основе параметров действия
        # @return [Hash]
        #   результирующий ассоциативный массив
        def request_attrs
          { case_id: params[:case_id], created_at: Time.now }
        end

        # Список ключей ассоциативного массива параметров, исключаемых из
        # сохранения в записях атрибутов межведомственного запроса
        BANNED_NAMES = %i[id case_id created_at].freeze

        # Возвращает, находится ли аргумент среди ключей ассоциативного массива
        # параметров, исключаемых из сохранения в записях атрибутов
        # межведомственного запроса
        # @param [Symbol] name
        #   ключ ассоциативного массива параметров
        # @return [Boolean]
        #   находится ли аргумент среди ключей ассоциативного массива
        #   параметров, исключаемых из сохранения в записях атрибутов
        #   межведомственного запроса
        def banned_name?(name)
          BANNED_NAMES.include?(name)
        end

        # Возвращает список трёхэлементных списков со значениями полей записей
        # атрибутов межведомственного запроса
        # @param [Integer] request_id
        #   идентификатор записи межведомственного запроса
        # @return [Array<Array<(Integer, String, Object)>>]
        #   результирующий список
        def import_values(request_id)
          params.each.each_with_object([]) do |(name, value), memo|
            memo << [request_id, name.to_s, value] unless banned_name?(name)
          end
        end

        # Названия полей записей атрибутов межведомственных запросов
        ATTRIBUTE_FIELDS = %i[request_id name value].freeze

        # Создаёт записи атрибутов межведомственного запроса
        # @param [CaseCore::Models::Request] request
        #   запись межведомственного запроса
        def create_attrs(request)
          attribute_values = import_values(request.id)
          Models::RequestAttribute.import(ATTRIBUTE_FIELDS, attribute_values)
        end
      end
    end
  end
end
