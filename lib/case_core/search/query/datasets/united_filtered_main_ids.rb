# frozen_string_literal: true

require_relative 'filtered_main_ids'

module CaseCore
  module Search
    class Query
      # Пространство имён классов объектов, создающих запросы Sequel
      module Datasets
        # Класс объектов, создающих запрос Sequel на извлечение идентификаторов
        # записей основной таблицы, которые отфильтрованы по значениям полей и
        # атрибутов
        class UnitedFilteredMainIDs
          # Инициализирует объект класса
          # @param [Class] main_model
          #   модель записей основной таблицы
          # @param [Class] attr_model
          #   модель записей атрибутов
          # @param [Array<Hash>] filters
          #   список ассоциативных массивов, ключами которых являются названия
          #   полей основной таблицы и атрибутов, а значениями — объекты с
          #   информацией об условиях на значения полей и атрибутов
          def initialize(main_model, attr_model, filters)
            @main_model = main_model
            @attr_model = attr_model
            @filters = filters
          end

          # Создаёт запрос Sequel на извлечение идентификаторов записей
          # основной таблицы, который отфильтрованы по значениям атрибутов, и
          # возвращает его. Возвращает `nil` в случае, если обнаружится
          # отсутствие условий.
          # @return [Sequel::Dataset]
          #   результирующий запрос Sequel
          # @return [NilClass]
          #   если обнаружится отсутствие условий
          def dataset
            return if filters.empty?
            datasets = filters.map(&method(:filtered_main_ids_dataset))
            return if datasets.find_index(nil)
            datasets.reduce { |memo, ds| memo.union(ds, from_self: false) }
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

          # Список ассоциативных массивов, ключами которых являются названия
          # полей основной таблицы и атрибутов, а значениями — объекты с
          # информацией об условиях на значения полей и атрибутов
          # @param [Array<Hash>] filters
          #   список ассоциативных массивов, ключами которых являются названия
          #   полей основной таблицы и атрибутов, а значениями — объекты с
          #   информацией об условиях на значения полей и атрибутов
          attr_reader :filters

          # Создаёт запрос Sequel на извлечение идентификаторов записей
          # основной таблицы, который отфильтрованы по значениям атрибутов, и
          # возвращает его. Возвращает `nil` в случае, если отсутствует
          # информация об условиях на значения полей и атрибутов.
          # @param [Hash] filter
          #   ассоциативный массив, ключами которого являются названия полей
          #   основной таблицы и атрибутов, а значениями — объекты с
          #   информацией об условиях на значения полей и атрибутов
          # @return [NilClass]
          #   если отсутствует информация об условиях на значения полей и
          #   атрибутов
          def filtered_main_ids_dataset(filter)
            FilteredMainIDs.new(main_model, attr_model, filter).dataset
          end
        end
      end
    end
  end
end
