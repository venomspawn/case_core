# frozen_string_literal: true

require_relative 'base/db'

module CaseCore
  module Tasks
    class Transfer
      class DataHub
        # Класс объектов, предоставляющих возможность работы с базой данных
        # `case_manager`
        class CaseManager < Base::DB
          # Список ассоциативных массивов с информацией о заявках
          # @return [Array<Hash>]
          #   список ассоциативных массивов с информацией о заявках
          attr_reader :cases

          # Ассоциативный массив, в котором идентификаторам записей реестров
          # передаваемой корреспонденции соответствуют ассоциативные массивы с
          # информацией об этих реестрах
          # @return [Hash]
          #   ассоциативный массив с информацией о реестрах передаваемой
          #   корреспонденции
          attr_reader :registers

          # Инициализирует объект класса
          def initialize
            settings = DataHub.settings
            host = settings.cm_host
            name = settings.cm_name
            user = settings.cm_user
            pass = settings.cm_pass
            super(:postgres, host, name, user, pass)
            initialize_collections
          end

          private

          # Инициализирует коллекции данных
          def initialize_collections
            @cases = db[:cases].to_a
            @registers = db[:registers].as_hash(:id)
          end
        end
      end
    end
  end
end
