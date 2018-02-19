# encoding: utf-8

module CaseCore
  module Search
    class Query
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Вспомогательный модуль, предназначенный для включения в тесты
      # содержащего класса
      #
      module SpecHelper
        # Ассоциативный массив, в котором моделям соответствуют списки
        # импортируемых значений
        #
        IMPORT = {
          Models::Case => [
                            ['1', 'test_case', Time.now ],
                            ['2', 'test_case', Time.now ],
                            ['3', 'spec_case', Time.now ],
                            ['4', 'spec_case', Time.now ],
                            ['5', 'spec_case', Time.now ]
                          ],
          Models::CaseAttribute => [
                                     %w(1 op_id 1abc),
                                     %w(1 state ok),
                                     %w(1 rguid 101),
                                     %w(2 op_id 2abc),
                                     %w(2 state error),
                                     %w(2 rguid 1001),
                                     %w(3 op_id 2bbc),
                                     %w(3 state closed),
                                     %w(3 rguid 10001),
                                     %w(4 op_id 2bbb),
                                     %w(4 state issue),
                                     %w(4 rguid 100001),
                                     %w(5 op_id 3abc),
                                     %w(5 state ok),
                                     %w(5 rguid 1000001),
                                   ]
        }

        # Создаёт записи заявок вместе с записями атрибутов, после чего
        # возвращает созданные записи заявок
        #
        # @return [Array<CaseCore::Models::Case>]
        #   список созданных записей заявок
        #
        def create_cases
          IMPORT.each { |model, values| model.import(model.columns, values) }
        end
      end
    end
  end
end
