# frozen_string_literal: true

require_relative 'transfer/data_hub'
require_relative 'transfer/importers/cases'
require_relative 'transfer/importers/documents'
require_relative 'transfer/importers/registers'
require_relative 'transfer/importers/requests'

module CaseCore
  module Tasks
    # Класс объектов, осуществляющих миграцию данных из `case_manager`
    class Transfer
      # Возвращает ассоциативный массив со статистикой по импортированным
      # атрибутам
      # @return [Hash]
      #   ассоциативный массив со статистикой по импортированным атрибутам
      def self.stats
        @stats ||= {}
      end

      # Создаёт экземпляр класса и запускает миграцию данных
      def self.launch!
        new.launch!
      end

      # Запускает миграцию данных
      def launch!
        hub = DataHub.new
        Sequel::Model.db.transaction do
          Importers::Cases.import(hub)
          Importers::Requests.import(hub)
          Importers::Documents.import(hub)
        end
        Importers::Registers.import(hub)
      end
    end
  end
end
