# frozen_string_literal: true

require "#{$lib}/actions/base/action"
require "#{$lib}/search/query"

module CaseCore
  module Actions
    module Cases
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Класс действия подсчёта количества записей заявок
      #
      class Count < Base::Action
        require_relative 'count/params_schema'
        require_relative 'count/result_schema'

        # Возвращает ассоциативный массив с количеством записей заявок
        #
        # @return [Hash]
        #   ассоциативный массив с единственным атрибутом `count`, содержащим
        #   количество записей заявок
        #
        def count
          { count: dataset.count }
        end

        private

        # Возвращает запрос Sequel на извлечение записей основной таблицы,
        # отвечающих параметрам
        #
        # @return [Sequel::Dataset]
        #   результирующий запрос Sequel
        #
        def dataset
          Search::Query.dataset(Models::Case, Models::CaseAttribute, params)
        end
      end
    end
  end
end
