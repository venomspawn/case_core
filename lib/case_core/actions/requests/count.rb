# encoding: utf-8

require "#{$lib}/actions/base/action"
require "#{$lib}/search/query"

module CaseCore
  module Actions
    module Requests
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Класс действий над записями межведомственных запросов, предоставляющий
      # метод `count`, который возвращает информацию о количестве
      # межведомственных запросов, созданных в рамках заявки
      #
      class Count < Base::Action
        require_relative 'count/params_schema'
        require_relative 'count/result_schema'

        include ParamsSchema
        include ResultSchema

        # Возвращает ассоциативный массив с информацией о количестве
        # межведомственных запросов, созданных в рамках заявки
        #
        # @return [Hash{count: Integer}]
        #   результирующий ассоциативный массив
        #
        # @raise [Sequel::NoMatchingRow]
        #   если запись заявки не найдена
        #
        def count
          { count: dataset.count }
        end

        private

        # Возвращает запись заявки
        #
        # @return [CaseCore::Models::Case]
        #   запись заявки
        #
        # @raise [Sequel::NoMatchingRow]
        #   если запись заявки не найдена
        #
        def record
          @record ||= Models::Case.with_pk!(id)
        end

        # Возвращает значение атрибута `id` ассоциативного массива параметров
        #
        # @return [Object]
        #   результирующее значение
        #
        def id
          params[:id]
        end

        # Возвращает ассоциативный массив параметров создания запроса Sequel на
        # получение записей основной таблицы
        #
        # @return [Hash]
        #   результирующий ассоциативный массив параметров
        #
        def query_params
          params.dup.tap { |result| result[:filter] = query_filters }
        end

        # Возвращает объект с условиями на поля записей и атрибуты
        # межведомственных запросов
        #
        # @return [Array<Hash>, Hash]
        #   результирующий объект
        #
        def query_filters
          obj = params[:filter]
          return obj.map(&method(:query_filter)) if obj.is_a?(Array)
          query_filter(obj)
        end

        # Возвращает ассоциативный массив с условиями на поля записей и
        # атрибуты межведомственных запросов, построенный на основе аргумента
        #
        # @param [NilClass, Hash] obj
        #   исходный объект с условиями
        #
        # @return [Hash]
        #   результирующий ассоциативный массив
        #
        def query_filter(obj)
          { case_id: record.id }.tap do |condition|
            condition.update(obj) if obj.is_a?(Hash)
          end
        end

        # Возвращает запрос Sequel на извлечение записей основной таблицы,
        # отвечающих параметрам
        #
        # @return [Sequel::Dataset]
        #   результирующий запрос Sequel
        #
        def dataset
          main_model = Models::Request
          attr_model = Models::RequestAttribute
          Search::Query.dataset(main_model, attr_model, query_params)
        end
      end
    end
  end
end
