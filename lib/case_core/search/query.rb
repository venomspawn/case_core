# frozen_string_literal: true

require_relative 'query/datasets/united_filtered_main_ids'

module CaseCore
  # Пространство имён классов объектов, посвящённых поиску записей
  module Search
    # Класс, предоставляющий функции выборки и подсчёта количества записей
    class Query
      # Возвращает запрос Sequel на получение записей. Выборка поддерживает
      # условия на значения полей и атрибутов, сортировку по значениям полей
      # основной таблицы, сдвиг и ограничение на количество возвращаемых
      # записей.
      # @param [Class] main_model
      #   модель записей основной таблицы
      # @param [Class] attr_model
      #   модель записей атрибутов
      # @param [Hash] params
      #   ассоциативный массив параметров выборки. Все ключи в этом
      #   ассоциативном массиве, а также в ассоциативных массивах, вложенных в
      #   него, должны быть приведены к типу Symbol. Поддерживаются следующие
      #   параметры (ключи).
      #
      #   *   `filter` — значение параметра интерпретируется в качестве условий
      #       на значения полей и атрибутов. В качестве значений поддерживаются
      #       только ассоциативные массивы или `nil`.
      #   *   `limit` — значение параметра интерпретируется в качестве
      #       ограничения на количество записей, возвращаемых результирующим
      #       запросом.
      #   *   `offset` — значение параметра интерпретируется в качестве сдвига
      #       в списке записей, возвращаемых результирующим запросом.
      #   *   `order` — значение параметра может быть только ассоциативным
      #       массивом, ключи которого интерпретируются как названия полей, по
      #       которым должны быть отсортированы записи, возвращаемые
      #       результирующим запросом, а значения задают направление сортировки
      #       и могут принимать лишь значения `asc` (по возрастанию) и `desc`
      #       (по убыванию). Поддерживаются лишь названия полей основной
      #       таблицы. Если значение параметра не указано, но присутствует хотя
      #       бы один из параметров `limit` или `offset` с непустым значением,
      #       то подразумевается, что сортировка идёт по возрастанию поля `id`.
      # @return [Sequel::Dataset]
      #   результирующий запрос Sequel
      def self.dataset(main_model, attr_model, params)
        new(main_model, attr_model, params).dataset
      end

      # Инициализирует объект класса
      # @param [Class] main_model
      #   модель записей основной таблицы
      # @param [Class] attr_model
      #   модель записей атрибутов
      # @param [Hash] params
      #   ассоциативный массив параметров выборки
      def initialize(main_model, attr_model, params)
        @main_model = main_model
        @attr_model = attr_model
        @params = params
      end

      # Возвращает запрос Sequel на получение записей
      # @return [Sequel::Dataset]
      #   результирующий запрос Sequel
      def dataset
        filtered_dataset.limit(limit).offset(offset).order(*order_columns)
      end

      private

      # Модель записей основной таблицы
      # @return [Class]
      #   модель записей основной таблицы
      attr_reader :main_model

      # Модель записей атрибутов
      # @return [Class]
      #   модель записей атрибутов
      attr_reader :attr_model

      # Ассоциативный массив параметров
      # @return [Hash]
      #   ассоциативный массив параметров
      attr_reader :params

      # Возвращает значение параметра `filter`
      # @return [Object]
      #   значение параметра `filter`
      def filter
        params[:filter]
      end

      # Возвращает значение параметра `limit`
      # @return [Object]
      #   значение параметра `limit`
      def limit
        params[:limit]
      end

      # Возвращает значение параметра `offset`
      # @return [Object]
      #   значение параметра `offset`
      def offset
        params[:offset]
      end

      # Возвращает значение параметра `order` или значение по умолчанию, если
      # значение отсутствует
      # @return [Hash]
      #   результирующее значение
      def order
        @order ||= params[:order] || default_order
      end

      # Возвращает значение параметра `order` по умолчанию
      # @return [Hash]
      #   значение параметра `order` по умолчанию
      def default_order
        limit.nil? && offset.nil? ? {} : { id: :asc }
      end

      # Возвращает список с информацией о сортировке записей
      # @return [Array<Sequel::SQL::OrderedExpression>]
      #   результирующий список
      def order_columns
        order.map { |key, dir| Sequel.send(dir, key) }
      end

      # Возвращает запрос Sequel на получение идентификаторов записей основной
      # таблицы, удовлетворяющих условиям
      # @return [Sequel::Dataset]
      #   результирующий запрос
      def main_ids_dataset
        Datasets::UnitedFilteredMainIDs
          .new(main_model, attr_model, filter)
          .dataset
      end

      # Возвращает запрос Sequel на получение записей основной таблицы,
      # удовлетворяющих условиям
      # @return [Sequel::Dataset]
      #   результирующий запрос
      def filtered_dataset
        return main_model.dataset if filter.nil?
        main_model.where(id: main_ids_dataset)
      end
    end
  end
end
