# encoding: utf-8

require "#{$lib}/actions/base/action"

# Предварительное создание класса, чтобы не надо было указывать в дальнейшем
# базовый класс
CaseCore::Actions::Cases::Index = Class.new(CaseCore::Actions::Base::Action)

require_relative 'index/attr_value_condition'
require_relative 'index/field_condition'
require_relative 'index/params_schema'
require_relative 'index/result_schema'

module CaseCore
  module Actions
    module Cases
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Класс действий над записями заявок, предоставляющий метод `index`,
      # который возвращает список ассоциативных массивов атрибутов заявок
      #
      class Index
        include ParamsSchema
        include ResultSchema

        # Возвращает список ассоциативных массивов атрибутов заявок
        #
        # @return [Array<Hash>]
        #   список ассоциативных массивов атрибутов заявок
        #
        def index
          fields? && attr_names.empty? ? index_without_attrs : index_with_attrs
        end

        private

        # Возвращает, присутствует ли непустое значение атрибута `fields` в
        # ассоциативном массиве параметров
        #
        # @return [Boolean]
        #   присутствует ли непустое значение атрибута `fields` в ассоциативном
        #   массиве параметров
        #
        def fields?
          params[:fields].present?
        end

        # Возвращает список полей для извлечения, если присутствует непустое
        # значение атрибута `fields` в ассоциативном массиве параметров, или
        # пустой список в противном случае
        #
        # @return [Array]
        #   результирующий список
        #
        def fields
          @fields ||= Array(params[:fields] || [])
        end

        # Возвращает ограничение на количество возвращаемых записей,
        # предоставленное в атрибуте `limit` ассоциативного массива параметров,
        # или `nil`, если атрибут отсутствует
        #
        # @return [Object]
        #   результирующее значение
        #
        def limit
          @limit ||= params[:limit]
        end

        # Возвращает сдвиг в таблице записей, от которого будут искаться
        # заявки, предоставленный в атрибуте `offset` ассоциативного массива
        # параметров, или `nil`, если атрибут отсутствует
        #
        # @return [Object]
        #   результирующее значение
        #
        def offset
          @offset ||= params[:offset]
        end

        # Возвращает список названий полей записи заявки, извлекаемых из базы
        # данных, на основе значения поля `fields` ассоциативного массива
        # параметров действия
        #
        # @return [Array]
        #   результирующий список названий полей
        #
        def case_fields
          @case_fields ||= if fields?
                             Models::Case.columns & fields
                           else
                             Models::Case.columns
                           end
        end

        # Возвращает список имён атрибутов заявок, по которым нужно производить
        # поиск в таблице атрибутов заявок
        #
        # @return [Array]
        #   результирующий список имён
        #
        def attr_names
          @attr_names ||= (fields - case_fields).map(&:to_s)
        end

        # Возвращает значение атрибута `filter` в ассоциативном массиве
        # параметров. В случае, если значение атрибута отсутствует, возвращает
        # пустой ассоциативный массив.
        #
        # @return [Hash]
        #   результирующий ассоциативный массив
        #
        def filter
          @filter ||= params[:filter] || {}
        end

        # Возвращает ассоциативный массив условий на поля таблицы заявок
        #
        # @return [Hash]
        #   результирующий ассоциативный массив
        #
        def filter_cases
          @filter_cases ||= filter.slice(*Models::Case.columns)
        end

        # Возвращает ассоциативный массив условий на атрибуты заявок в
        # соответствующей таблице
        #
        # @return [Hash]
        #   результирующий ассоциативный массив
        #
        def filter_attrs
          @filter_attrs ||= filter.except(*Models::Case.columns)
        end

        # Возвращает запрос Sequel на получение записей из таблицы заявок с
        # учётом условий на поля, а также, возможно, с учётом идентификаторов
        # записей, найденных в таблице атрибутов заявок
        #
        # @param [Boolean] use_attrs
        #   использовать запрос на получение идентификаторов записей, найденных
        #   в таблице атрибутов заявок, для дополнительной фильтрации
        #
        # @return [Sequel::Dataset]
        #   результирующий запрос
        #
        def cases_dataset(use_attrs = true)
          dataset = Models::Case.dataset

          if use_attrs && filter_attrs.present?
            ids = attrs_dataset.select(:case_id)
            dataset = dataset.where(id: ids)
          end

          dataset = filter_cases.reduce(dataset) do |memo, (field, value)|
            cond = FieldCondition.condition(field, value)
            memo = memo.where(cond)
          end
        end

        # Возвращает запрос Sequel на получение записей из таблицы заявок с
        # учётом условий на поля, а также ограничений на количество записей и
        # сдвига в таблице
        #
        # @return [Sequel::Dataset]
        #   результирующий запрос
        #
        def result_cases_dataset
          dataset = cases_dataset
          dataset = dataset.limit(limit) if limit.present?
          dataset = dataset.offset(offset) if offset.present?
          dataset
        end

        # Возвращает запрос Sequel на получение записей из таблицы атрибутов
        # заявок с учётом условий на атрибуты заявок
        #
        # @return [Sequel::Dataset]
        #   результирующий запрос
        #
        def attrs_dataset
          dataset = CaseCore::Models::CaseAttribute.dataset

          if filter_cases.present?
            case_ids = cases_dataset(false).select(:id)
            dataset = dataset.where(case_id: case_ids)
          end

          filter_attributes.reduce(dataset) do |memo, (name, value)|
            cond = AttrValueCondition.condition(name, value)
            memo = memo.where(cond)
          end
        end

        # Возвращает запрос Sequel на получение записей из таблицы атрибутов
        # заявок для заявок с данными идентификаторами записей
        #
        # @param [NilClass, Array]
        #   список идентификаторов записей заявок или `nil`, если необходимо
        #   извлечь атрибуты всех заявок
        #
        # @return [Sequel::Dataset]
        #   результирующий запрос
        #
        def result_attrs_dataset(case_ids)
          dataset = Models::CaseAttribute.dataset
          dataset = dataset.where(case_id: case_ids) unless case_ids.nil?
          dataset = dataset.where(name: attr_names) unless attr_names.empty?
          dataset
        end

        # Возвращает список ассоциативных массивов атрибутов заявок,
        # составленных только по атрибутам записей заявок в таблице заявок
        #
        # @return [Array<Hash>]
        #   результирующий список
        #
        def index_without_attrs
          result_cases_dataset.select(*case_fields).naked.to_a
        end

        # Возвращает список ассоциативных массивов атрибутов заявок,
        # составленных по атрибутам записей заявок в таблице заявок, а также по
        # атрибутам, хранящимся в таблице атрибутов заявок
        #
        # @return [Array<Hash>]
        #   результирующий список
        #
        def index_with_attrs
          cases = result_cases_dataset.select_hash(:id, case_fields)
          case_ids = cases.keys if filter.present?
          dataset = result_attrs_dataset(case_ids)
          attrs_info = dataset.select_hash_groups(:case_id, %i[name value])
          attrs_info.each_with_object([]) do |(case_id, attrs), memo|
            case_values = cases[case_id]
            case_hash = Hash[case_fields.zip(case_values)]
            memo << Hash[attrs].merge(case_hash)
          end
        end
      end
    end
  end
end
