# encoding: utf-8

module CaseCore
  module Actions
    module Base
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Пространство имён модулей, подключаемых к классам действий
      #
      module Mixins
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Модуль, предоставляющий метод-обёртку вокруг метода `transaction`
        # объекта класса `Sequel::Database`
        #
        module Transactional
          # Настройки транзакции
          #
          TRANSACTION_OPTIONS = { savepoint: true }

          # Предоставляет блок методу `transaction` объекту базы данных Sequel
          #
          def transaction(&block)
            Sequel::Model.db.transaction(TRANSACTION_OPTIONS, &block)
          end
        end
      end
    end
  end
end
