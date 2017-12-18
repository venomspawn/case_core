# encoding: utf-8

require "#{$lib}/actions/base/action"

# Предварительное создание класса, чтобы не надо было указывать в дальнейшем
# базовый класс
CaseCore::Actions::Requests::Show = Class.new(CaseCore::Actions::Base::Action)

require_relative 'show/params_schema'
require_relative 'show/result_schema'

module CaseCore
  module Actions
    module Requests
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Класс действий над записями межведомственных запросов, предоставляющих
      # метод `show`, который возвращает информацию о межведомственном запросе
      #
      class Show
        include ParamsSchema
        include ResultSchema

        # Возвращает ассоциативный массив со всеми атрибутами межведомственного
        # запроса
        #
        # @return [Hash]
        #   результирующий ассоциативный массив
        #
        # @raise [Sequel::NoMatchingRow]
        #   если запись заявки не найдена
        #
        def show
          attributes_dataset = record.attributes_dataset.naked
          attributes_dataset.select_hash(:name, :value, hash: record.values)
        end

        private

        # Возвращает запись межведомственного запроса
        #
        # @return [CaseCore::Models::Request]
        #   запись межведомственного запроса
        #
        # @raise [Sequel::NoMatchingRow]
        #   если запись межведомственного запроса не найдена
        #
        def record
          @record ||= CaseCore::Models::Request.with_pk!(id)
        end

        # Возвращает значение атрибута `id` ассоциативного массива параметров
        #
        # @return [Object]
        #   результирующее значение
        #
        def id
          params[:id]
        end
      end
    end
  end
end
