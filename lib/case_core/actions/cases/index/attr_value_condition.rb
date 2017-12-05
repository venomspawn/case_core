# encoding: utf-8

require_relative 'field_condition'

module CaseCore
  module Actions
    module Cases
      class Index
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Модуль, предоставляющий вспомогательные функции для составления
        # запросов Sequel к таблице атрибутов заявок
        #
        module AttrValueCondition
          # Возвращает условие для запроса Sequel к таблице атрибутов заявок
          #
          # @param [#to_s] name
          #   название атрибута
          #
          # @param [Object] value
          #   либо значение атрибута, либо значения атрибута, либо некоторое
          #   условие, задаваемое в виде ассоциативного массива. Поддерживаются
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
          # @return [Sequel::SQL::BooleanExpression]
          #   результирующее условие
          #
          def self.condition(name, value)
            value_cond = FieldCondition.condition(:value, value)
            Sequel.&({ name: name.to_s }, value_cond)
          end
        end
      end
    end
  end
end
