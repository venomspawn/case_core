# frozen_string_literal: true

require "#{$lib}/actions/base/complex_index"

module CaseCore
  module Actions
    module Requests
      # Класс действий над записями межведомственных запросов, предоставляющий
      # метод `index`, который возвращает список ассоциативных массивов
      # атрибутов межведомственных запросов, созданных в рамках заявки
      class Index < Base::ComplexIndex
        require_relative 'index/params_schema'
        require_relative 'index/result_schema'

        private

        # Возвращает запись заявки
        # @return [CaseCore::Models::Case]
        #   запись заявки
        # @raise [Sequel::NoMatchingRow]
        #   если запись заявки не найдена
        def record
          @record ||= Models::Case.with_pk!(id)
        end

        # Возвращает значение атрибута `id` ассоциативного массива параметров
        # @return [Object]
        #   результирующее значение
        def id
          params[:id]
        end

        # Возвращает значение атрибута `filter` ассоциативного массива
        # параметров
        # @return [Object]
        #   результирующее значение
        def filter
          params[:filter]
        end

        # Возвращает ассоциативный массив параметров создания запроса Sequel на
        # получение записей основной таблицы
        # @return [Hash]
        #   результирующий ассоциативный массив параметров
        def query_params
          params.except(filter).tap do |result|
            result[:filter] = if filter.nil?
                                { case_id: record.id }
                              else
                                { and: [filter, case_id: record.id] }
                              end
          end
        end

        # Возвращает модель записей основной таблицы
        # @return [Class]
        #   модель записей основной таблицы
        def main_model
          Models::Request
        end

        # Возвращает модель записей таблицы атрибутов
        # @return [Class]
        #   модель записей таблицы атрибутов
        def attr_model
          Models::RequestAttribute
        end
      end
    end
  end
end
