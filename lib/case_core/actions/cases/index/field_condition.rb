# encoding: utf-8

module CaseCore
  module Actions
    module Cases
      class Index
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Модуль, предоставляющий вспомогательные функции для составления
        # запросов Sequel
        #
        module FieldCondition
          # Возвращает условие для запроса Sequel в виде ассоциативного
          # массива, объекта типа {Sequel::LiteralString} или объекта типа
          # {Sequel::SQL::Expression} для поля с заданным названием
          #
          # @param [String] field
          #   название поля
          #
          # @param [Object] value
          #   либо значение поля, либо значения поля, либо некоторое условие,
          #   задаваемое в виде ассоциативного массива. Поддерживаются
          #   следующие поля ассоциативного массива:
          #
          #   *   `min` (значение поля задаёт условие на нижнюю границу
          #       значений);
          #   *   `max` (значение поля задаёт условие на верхню границу
          #       значений);
          #   *   `exclude` (значение поля задаёт условие, которое будет
          #       изменено на противоположное).
          #
          #   В случае, если ассоциативный массив не обладает поддерживаемыми
          #   полями, описанными выше, то возвращается пустой ассоциативный
          #   массив.
          #
          # @return [Hash, Sequel::LiteralString, Sequel::SQL::Expression]
          #   результирующее условие
          #
          def self.condition(field, value)
            return eq(field, value) unless value.is_a?(Hash)

            exclude_value = value[:exclude]
            return neg(field, exclude_value) if exclude_value.present?

            min_value = value[:min]
            max_value = value[:max]
            range_present = min_value.present? && max_value.present?
            return range(field, min_value, max_value) if range_present
            return lt(min_value, field) if min_value.present?
            return lt(field, max_value) if max_value.present?

            {}
          end

          # Возвращает условие Sequel на конкретные значения предоставленного
          # поля в виде ассоциативного массива
          #
          # @param [String] field
          #   название поля
          #
          # @param [Object] value
          #   значение или значения поля
          #
          # @return [Hash]
          #   результирующий ассоциативный массив
          #
          def self.eq(field, value)
            { field => value }
          end

          # Возвращает условие Sequel, являющееся отрицанием предоставленного
          # условия
          #
          # @param [String] field
          #   название поля
          #
          # @param [Object] value
          #   условие на поле
          #
          # @return [Sequel::SQL::BooleanExpression]
          #   результирующее условие Sequel
          #
          def self.neg(field, value)
            cond = condition(field, value)
            Sequel.~(cond)
          end

          # Возвращает условие Sequel на то, что одно значение `a` меньше
          # другого значения `b`
          #
          # @param [Object] a
          #   первое значение
          #
          # @param [Object] b
          #   второе значение
          #
          # @return [Sequel::LiteralString]
          #   результирующее условие Sequel
          #
          def self.lt(a, b)
            Sequel.lit('? <= ?', a, b)
          end

          # Возвращает условие Sequel на то, что значения поля находятся в
          # диапазоне
          #
          # @param [String] field
          #   название поля
          #
          # @param [Object] min_value
          #   нижняя граница значений
          #
          # @param [Object] max_value
          #   верхняя граница значений
          #
          # @return [Sequel::LiteralString]
          #   результирующее условие Sequel
          #
          def self.range(field, min_value, max_value)
            min = lt(min_value, field)
            max = lt(field, max_value)
            Sequel.&(min, max)
          end
        end
      end
    end
  end
end
