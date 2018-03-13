# frozen_string_literal: true

module CaseCore
  module Search
    class Query
      module Expressions
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Модуль, предоставляющий константы подключающим классам
        #
        module Consts
          # SQL-выражение Sequel, которое всегда возвращает булеву истину
          #
          TRUE = Sequel::SQL::BooleanExpression.new(:NOOP, true)
        end
      end
    end
  end
end
