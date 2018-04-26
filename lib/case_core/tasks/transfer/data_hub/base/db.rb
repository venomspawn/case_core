# frozen_string_literal: true

module CaseCore
  module Tasks
    class Transfer
      class DataHub
        # Пространство имён базовых классов объектов, предоставляющих доступ к
        # данным
        module Base
          # Базовый класс объектов, предоставляющих доступ к данным
          class DB
            # Инициализирует объект класса
            # @param [String] adapter
            #   адаптер базы данных
            # @param [String] host
            #   название сервера базы данных
            # @param [String] name
            #   название базы данных
            # @param [String] user
            #   название учётной записи пользователя базы данных
            # @param [String] pass
            #   пароль учётной записи пользователя базы данных
            def initialize(adapter, host, name, user, pass)
              params = {
                adapter:  adapter,
                host:     host,
                database: name,
                user:     user,
                password: pass
              }
              @db = Sequel.connect(params)
            end

            private

            # Объект, предоставляющий доступ к базе данных
            # @return [Sequel::Database]
            #   объект, предоставляющий доступ к базе данных
            attr_reader :db
          end
        end
      end
    end
  end
end
