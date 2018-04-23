# frozen_string_literal: true

require_relative 'base/db'

module CaseCore
  module Tasks
    class Transfer
      class DataHub
        # Класс объектов, предоставляющих возможность работы с базой данных
        # `cabinet`
        class Cabinet < Base::DB
          # Инициализирует объект класса
          def initialize
            settings = DataHub.settings
            host = settings.cab_host
            name = settings.cab_name
            user = settings.cab_user
            pass = settings.cab_pass
            super(:mysql2, host, name, user, pass)
            initialize_collections
          end

          private

          # Инициализирует коллекции данных
          def initialize_collections
          end
        end
      end
    end
  end
end
