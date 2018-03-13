# frozen_string_literal: true

require "#{$lib}/actions/base/action"

module CaseCore
  module Actions
    module Requests
      # Класс действий над записями межведомственных запросов, предоставляющих
      # метод `show`, который возвращает информацию о межведомственном запросе
      class Show < Base::Action
        require_relative 'show/params_schema'
        require_relative 'show/result_schema'

        # Возвращает ассоциативный массив со всеми атрибутами межведомственного
        # запроса
        # @return [Hash]
        #   результирующий ассоциативный массив
        # @raise [Sequel::NoMatchingRow]
        #   если запись заявки не найдена
        def show
          attributes_dataset = record.attributes_dataset.naked
          attributes_dataset.select_hash(:name, :value, hash: record.values)
        end

        private

        # Возвращает запись межведомственного запроса
        # @return [CaseCore::Models::Request]
        #   запись межведомственного запроса
        # @raise [Sequel::NoMatchingRow]
        #   если запись межведомственного запроса не найдена
        def record
          @record ||= CaseCore::Models::Request.with_pk!(id)
        end

        # Возвращает значение атрибута `id` ассоциативного массива параметров
        # @return [Object]
        #   результирующее значение
        def id
          params[:id]
        end
      end
    end
  end
end
