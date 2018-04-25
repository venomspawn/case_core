# frozen_string_literal: true

require_relative 'base/db'

module CaseCore
  module Tasks
    class Transfer
      class DataHub
        # Класс объектов, предоставляющих возможность работы с базой данных
        # `org_struct`
        class OrgStruct < Base::DB
          # Ассоциативный массив, в котором идентификаторам карточек офисов
          # сопоставлены ассоциативные массивы с информацией об офисах
          # @return [Hash]
          #   ассоциативный массив с информацией об офисах
          attr_reader :offices

          # Ассоциативный массив, в котором идентификаторам карточек офисов
          # сопоставлены ассоциативные массивы с информацией об адресах этих
          # офисов
          # @return [Hash]
          #   ассоциативный массив с информацией об адресах офисов
          attr_reader :addresses

          # Ассоциативный массив, в котором идентификаторам карточек
          # сотрудников сопоставлены ассоциативные массивы с информацией о
          # сотрудниках
          # @return [Hash]
          #   ассоциативный массив с информацией о сотрудниках
          attr_reader :employees

          # Инициализирует объект класса
          def initialize
            settings = DataHub.settings
            host = settings.os_host
            name = settings.os_name
            user = settings.os_user
            pass = settings.os_pass
            super(:postgres, host, name, user, pass)
            initialize_collections
          end

          private

          # Инициализирует коллекции данных
          def initialize_collections
            initialize_offices
            initialize_addresses
            initialize_employees
          end

          # Инициализирует коллекцию данных карточек офисов организационной
          # структуры
          def initialize_offices
            @offices = db[:offices].as_hash(:id)
          end

          # Инициализирует коллекцию данных адресов офисов организационной
          # структуры
          def initialize_addresses
            @addresses = offices.each_with_object({}) do |(id, office), memo|
              next if office[:address].blank?
              memo[id] = JSON.parse(office[:address], symbolize_names: true)
            end
          end

          # Инициализирует коллекцию данных карточек сотрудников
          # организационной структуры
          def initialize_employees
            @employees = db[:employees].as_hash(:id)
          end
        end
      end
    end
  end
end
