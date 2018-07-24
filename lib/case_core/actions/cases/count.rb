# frozen_string_literal: true

module CaseCore
  need 'actions/base/action'
  need 'search/query'

  module Actions
    module Cases
      # Класс действия подсчёта количества записей заявок
      class Count < Base::Action
        require_relative 'count/params_schema'

        # Возвращает ассоциативный массив с количеством записей заявок
        # @return [Hash]
        #   ассоциативный массив с единственным атрибутом `count`, содержащим
        #   количество записей заявок
        def count
          { count: dataset.count }
        end

        private

        # Возвращает запрос Sequel на извлечение записей основной таблицы,
        # отвечающих параметрам
        # @return [Sequel::Dataset]
        #   результирующий запрос Sequel
        def dataset
          Search::Query.dataset(Models::Case, Models::CaseAttribute, params)
        end
      end
    end
  end
end
