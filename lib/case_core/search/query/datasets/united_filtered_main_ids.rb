# frozen_string_literal: true

require 'json-schema'

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
          # @param [Hash] filter
          #   ассоциативный массив с информацией об условиях на поля и атрибуты
          def initialize(main_model, attr_model, filter)
            @main_model = main_model
            @attr_model = attr_model
            @filter = filter
          end

          # Создаёт запрос Sequel на извлечение идентификаторов записей
          # основной таблицы, который отфильтрованы по значениям атрибутов, и
          # возвращает его
          # @return [Sequel::Dataset]
          #   результирующий запрос Sequel
          def dataset
            op.nil? ? filtered_main_ids_dataset : booleaned_main_ids_dataset
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

          # Ассоциативный массив с условиями на поля и атрибуты
          # @return [Hash]
          #   ассоциативный массив с условиями на поля и атрибуты
          attr_reader :filter

          # JSON-схема проверки значения ассоциативного массива условий по
          # ключу `or`
          OR_SCHEMA = {
            type: :object,
            properties: {
              or: {
                type: :array,
                items: {
                  type: :object
                },
                minItems: 1
              }
            },
            required: %i[
              or
            ],
            additionalProperties: false
          }.freeze

          # Возвращает, удовлетворяет ли ассоциативный массив условий
          # JSON-схеме {OR_SCHEMA}
          # @return [Boolean]
          #   удовлетворяет ли ассоциативный массив условий JSON-схеме
          #   {OR_SCHEMA}
          def or?
            JSON::Validator.validate(OR_SCHEMA, filter, parse_data: false)
          end

          # JSON-схема проверки значения ассоциативного массива условий по
          # ключу `and`
          AND_SCHEMA = {
            type: :object,
            properties: {
              and: {
                type: :array,
                items: {
                  type: :object
                },
                minItems: 1
              }
            },
            required: %i[
              and
            ],
            additionalProperties: false
          }.freeze

          # Возвращает, удовлетворяет ли ассоциативный массив условий
          # JSON-схеме {AND_SCHEMA}
          # @return [Boolean]
          #   удовлетворяет ли ассоциативный массив условий JSON-схеме
          #   {AND_SCHEMA}
          def and?
            JSON::Validator.validate(AND_SCHEMA, filter, parse_data: false)
          end

          # Возвращает название метода объекта или `nil` в зависимости от того,
          # какие значения возвращают методы {or?} и {and?}
          # @return [:intersect]
          #   если метод {and?} вернул `true`
          # @return [:union]
          #   если метод {or?} вернул `true`
          # @return [NilClass]
          #   если и метод {or?}, и метод {and?} вернули `false`
          def op
            return @op if defined?(@op)
            @op = if and?
                    :intersect
                  elsif or?
                    :union
                  end
          end

          # Создаёт запрос Sequel на извлечение идентификаторов записей
          # основной таблицы, который отфильтрованы по значениям атрибутов, и
          # возвращает его
          # @return [Sequel::Dataset]
          #   результирующий запрос Sequel
          def filtered_main_ids_dataset
            FilteredMainIDs.new(main_model, attr_model, filter).dataset
          end

          # Возвращает запрос Sequel, полученный пересечением исходных запросов
          # @param [Sequel::Dataset] memo
          #   исходный запрос Sequel
          # @param [Sequel::Dataset] dataset
          #   ещё один исходный запрос Sequel
          # @return [Sequel::Dataset]
          #   запрос Sequel, полученный пересечением исходных запросов
          def intersect(memo, dataset)
            memo.intersect(dataset)
          end

          # Возвращает запрос Sequel, полученный объединением исходных запросов
          # @param [Sequel::Dataset] memo
          #   исходный запрос Sequel
          # @param [Sequel::Dataset] dataset
          #   ещё один исходный запрос Sequel
          # @return [Sequel::Dataset]
          #   запрос Sequel, полученный объединением исходных запросов
          def union(memo, dataset)
            memo.union(dataset)
          end

          # Возвращает запрос Sequel на извлечение идентификаторов записей
          # основной таблицы согласно булевым операциям
          # @return [Sequel::Dataset]
          #   результирующий запрос Sequel
          def booleaned_main_ids_dataset
            filters = filter[:or] || filter[:and]
            datasets = filters.map do |f|
              UnitedFilteredMainIDs.new(main_model, attr_model, f).dataset
            end
            datasets.reduce(&method(op))
          end
        end
      end
    end
  end
end
