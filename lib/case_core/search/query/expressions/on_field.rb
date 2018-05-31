# frozen_string_literal: true

require_relative 'consts'

module CaseCore
  module Search
    class Query
      # Модуль классов объектов, составляющих SQL-выражения Sequel
      module Expressions
        # Класс объектов, которые составляют SQL-выражение Sequel, выставляющих
        # условия на значения полей таблиц
        class OnField
          include Consts

          # Инициализирует объект класса
          # @param [Object] identifier
          #   объект идентификатора
          # @param [Object] info
          #   объект с информацией об условии на поле
          def initialize(identifier, info)
            @identifier = identifier
            @info       = info
          end

          # Названия методов объекта, возвращающих условия
          METHOD_NAMES = %i[exclude like min max].freeze

          # Составляет SQL-выражение Sequel, выставляющее условие на значение
          # поля таблицы, и возвращает его
          # @return [Sequel::SQL::ComplexExpression]
          #   результирующее выражение
          def expression
            info.is_a?(Hash) ? from_info : eq
          end

          private

          # Объект идентификатора
          # @return [Object]
          #   объект идентификатора
          attr_reader :identifier

          # Объект с информацией об условии на поле
          # @return [Object]
          #   объект с информацией об условии на поле
          attr_reader :info

          # Возвращает выражение, выставляющее условие на равенство
          # @return [Sequel::SQL::BooleanExpression]
          #   результирующее выражение
          def eq
            Sequel::SQL::BooleanExpression.from_value_pairs(identifier => info)
          end

          # Возвращает выражение, выставляющее условие на отрицание
          # @return [Sequel::SQL::ComplexExpression]
          #   результирующее выражение
          def exclude
            OnField.new(identifier, info[:exclude]).expression.~
          end

          # Возвращает выражение, выставляющее условие на частичное совпадение
          # @return [Sequel::SQL::StringExpression]
          #   результирующее выражение
          def like
            Sequel::SQL::StringExpression
              .like(identifier, info[:like], case_insensitive: true)
          end

          # Возвращает выражение, выставляющее условие на неравенство двух
          # значений
          # @return [Sequel::SQL::BooleanExpression]
          #   результирующее выражение
          def lte(left, right)
            Sequel::SQL::BooleanExpression.new(:<=, left, right)
          end

          # Возвращает выражение, выставляющее условие на максимальное значение
          # @return [Sequel::SQL::BooleanExpression]
          #   результирующее выражение
          def max
            lte(identifier, info[:max])
          end

          # Возвращает выражение, выставляющее условие на минимальное значение
          # @return [Sequel::SQL::BooleanExpression]
          #   результирующее выражение
          def min
            lte(info[:min], identifier)
          end

          # Возвращает выражение, выставляющее условие на значение поля
          # согласно ассоциативному массиву `info`
          # @return [Sequel::SQL::BooleanExpression]
          #   результирущее выражение
          def from_info
            method_names = METHOD_NAMES & info.keys
            return TRUE if method_names.empty?
            expressions = method_names.map(&method(:send))
            Sequel::SQL::BooleanExpression.new(:AND, *expressions)
          end
        end
      end
    end
  end
end
