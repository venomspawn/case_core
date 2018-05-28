# frozen_string_literal: true

require "#{$lib}/actions/base/action"
require "#{$lib}/search/query"

module CaseCore
  module Actions
    module Requests
      # Класс действий над записями межведомственных запросов, предоставляющий
      # метод `count`, который возвращает информацию о количестве
      # межведомственных запросов, созданных в рамках заявки
      class Count < Base::Action
        require_relative 'count/params_schema'
        require_relative 'count/result_schema'

        # Возвращает ассоциативный массив с информацией о количестве
        # межведомственных запросов, созданных в рамках заявки
        # @return [Hash{count: Integer}]
        #   результирующий ассоциативный массив
        # @raise [Sequel::NoMatchingRow]
        #   если запись заявки не найдена
        def count
          { count: dataset.count }
        end

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

        # Возвращает запрос Sequel на извлечение записей основной таблицы,
        # отвечающих параметрам
        # @return [Sequel::Dataset]
        #   результирующий запрос Sequel
        def dataset
          main_model = Models::Request
          attr_model = Models::RequestAttribute
          Search::Query.dataset(main_model, attr_model, query_params)
        end
      end
    end
  end
end
