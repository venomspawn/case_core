# frozen_string_literal: true

module CaseCore
  module Actions
    module Base
      # Пространство имён модулей, подключаемых к классам действий
      module Mixins
        # Модуль, предоставляющий метод-обёртку вокруг метода `transaction`
        # объекта класса `Sequel::Database`
        module Transactional
          # Настройки транзакции
          TRANSACTION_OPTIONS = { savepoint: true }.freeze

          # Предоставляет блок методу `transaction` объекту базы данных Sequel
          def transaction(&block)
            Sequel::Model.db.transaction(TRANSACTION_OPTIONS, &block)
          end
        end
      end
    end
  end
end
