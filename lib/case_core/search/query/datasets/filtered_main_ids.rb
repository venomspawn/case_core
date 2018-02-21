# encoding: utf-8

require_relative '../expressions/consts'
require_relative '../expressions/on_field'

module CaseCore
  module Search
    class Query
      module Datasets
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Класс объектов, создающих запрос Sequel на извлечение идентификаторов
        # записей основной таблицы, которые отфильтрованы по значениям полей и
        # атрибутов
        #
        class FilteredMainIDs
          include Expressions::Consts

          # Инициализирует объект класса
          #
          # @param [Class] main_model
          #   модель записей основной таблицы
          #
          # @param [Class] attr_model
          #   модель записей атрибутов
          #
          # @param [Hash] filter
          #   ассоциативный массив, ключами которого являются названия полей
          #   основной таблицы и атрибутов, а значениями — объекты с
          #   информацией об условиях на значения полей и атрибутов
          #
          def initialize(main_model, attr_model, filter)
            @main_model = main_model
            @attr_model = attr_model
            @main_filter = filter.slice(*main_model.columns)
            @attrs_filter = filter.except(*main_model.columns)
          end

          # Создаёт запрос Sequel на извлечение идентификаторов записей
          # основной таблицы, который отфильтрованы по значениям атрибутов, и
          # возвращает его. Возвращает `nil` в случае, если отсутствует
          # информация об условиях на значения полей и атрибутов.
          #
          # @return [Sequel::Dataset]
          #   результирующий запрос Sequel
          #
          # @return [NilClass]
          #   если отсутствует информация об условиях на значения полей и
          #   атрибутов
          #
          def dataset
            attrs_filter.reduce(main_ids_dataset) do |memo, (name, info)|
              ds = attr_foreign_keys_dataset(name, info)
              memo.nil? ? ds : ds.where(attr_foreign_key => memo)
            end
          end

          private

          # Модель записей основной таблицы
          #
          # @return [Class]
          #   модель записей основной таблицы
          #
          attr_reader :main_model

          # Модель записей атрибутов
          #
          # @return [Class]
          #   модель записей атрибутов
          #
          attr_reader :attr_model

          # Ассоциативный массив, ключами которого являются названия полей
          # основной таблицы, а значениями — объекты с информацией об условиях
          # на значения этих полей
          #
          # @return [Hash]
          #   ассоциативный массив, ключами которого являются названия полей
          #   основной таблицы, а значениями — объекты с информацией об
          #   условиях на значения этих полей
          #
          attr_reader :main_filter

          # Ассоциативный массив, ключами которого являются названия атрибутов,
          # а значениями — объекты с информацией об условиях на значения
          # атрибутов
          #
          # @return [Array<Hash>]
          #   ассоциативный массив, ключами которого являются названия
          #   атрибутов, а значениями — объекты с информацией об условиях на
          #   значения атрибутов
          #
          attr_reader :attrs_filter

          # Возвращает название внешнего ключа таблицы атрибутов
          #
          # @return [Symbol]
          #   название внешнего ключа таблицы атрибутов
          #
          def attr_foreign_key
            @attr_foreign_key ||=
              attr_model
              .association_reflections
              .each_value
              .find { |refl| refl.associated_class == main_model }
              .default_key
          end

          # Составляет SQL-выражение Sequel на основе предоставленных
          # SQL-выражений Sequel, соединяя их конъюнкцией
          #
          # @param [Array<Sequel::SQL::ComplexExpression>]
          #   список SQL-выражений Sequel
          #
          # @return [Sequel::SQL::BooleanExpression]
          #   результирующее выражение
          #
          def conjunction(expressions)
            expressions.delete(TRUE)
            return TRUE if expressions.empty?
            Sequel::SQL::BooleanExpression.new(:AND, *expressions)
          end

          # Составляет SQL-выражение Sequel, выставляющее условие на значение
          # поля таблицы, и возвращает его
          #
          # @param [#to_s] table
          #   название таблицы
          #
          # @param [#to_s] field
          #   название поля
          #
          # @param [Object] info
          #   объект с информацией об условии на поле. В случае, если значение
          #   не является объектом типа `Hash`, условием на поле является само
          #   значение. В случае, если значение является объектом типа `Hash`,
          #   условие составляется на основе его ключей и значений.
          #
          # @return [Sequel::SQL::ComplexExpression]
          #   результирующее выражение
          #
          def on_field(table, field, info)
            Expressions::OnField.new(table, field, info).expression
          end

          # Составляет SQL-выражение Sequel, выставляющее условие на значения
          # полей основной таблицы, и возвращает его
          #
          # @return [Sequel::SQL::BooleanExpression]
          #   результирующее выражение
          #
          def on_main
            expressions = main_filter.map do |field, info|
              on_field(main_model.table_name, field, info)
            end
            conjunction(expressions)
          end

          # Выражение для SQL-функции `value_is_short`, принимающей значения на
          # значениях атрибутов
          #
          VALUE_IS_SHORT = Sequel.function(:value_is_short, :value)

          # Составляет SQL-выражение Sequel, выставляющее условие на значение
          # атрибута, и возвращает его
          #
          # @param [#to_s] name
          #   название атрибута
          #
          # @param [Object] info
          #   объект с информацией об условии на атрибут
          #
          # @return [Sequel::SQL::BooleanExpression]
          #   результирующее выражение
          #
          def on_attr(name, info)
            on_name = on_field(attr_model.table_name, :name, name.to_s)
            on_value = on_field(attr_model.table_name, :value, info)
            conjunction([on_name, on_value, VALUE_IS_SHORT])
          end

          # Создаёт запрос Sequel на извлечение идентификаторов записей
          # основной таблицы, отфильтрованных по значениям их полей, и
          # возвращает его. Возвращает `nil` в случае, если отсутствует
          # информация об условиях на значения полей.
          #
          # @return [Sequel::Dataset]
          #   результирующий запрос Sequel
          #
          # @return [NilClass]
          #   если отсутствует информация об условиях на значения полей
          #
          def main_ids_dataset
            main_model.where(on_main).select(:id) unless main_filter.empty?
          end

          # Создаёт запрос Sequel на извлечение идентификаторов записей
          # основной таблицы, отфильтрованных по значениям атрибутов, и
          # возвращает его
          #
          # @param [#to_s] name
          #   название атрибута
          #
          # @param [Object] info
          #   объект с информацией об условии на атрибут
          #
          # @return [Sequel::Dataset]
          #   результирующий запрос Sequel
          #
          def attr_foreign_keys_dataset(name, info)
            expression = on_attr(name, info)
            attr_model.where(expression).select(attr_foreign_key)
          end
        end
      end
    end
  end
end
