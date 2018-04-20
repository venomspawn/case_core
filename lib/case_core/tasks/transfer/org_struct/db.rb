# frozen_string_literal: true

module CaseCore
  module Tasks
    class Transfer
      # Пространство имён классов объектов, оперирующих записями базы данных
      # `org_struct`
      module OrgStruct
        # Класс объектов, предоставляющих возможность работы с базой данных
        # `org_struct`
        class DB
          # Возвращает ассоциативный массив, в котором идентификаторам карточек
          # офисов сопоставлены ассоциативные массивы с информацией об офисах
          # @return [Hash]
          #   результирующий ассоциативный массив
          def offices
            @offices ||= db[:offices].each_with_object({}) do |office, memo|
              memo[office[:id]] = office
            end
          end

          # Возвращает ассоциативный массив, в котором идентификаторам карточек
          # офисов сопоставлены ассоциативные массивы с информацией об адресах
          # этих офисов
          # @return [Hash]
          #   результирующий ассоциативный массив
          def addresses
            @addresses ||= offices.each_with_object({}) do |(id, office), memo|
              next if office[:address].blank?
              memo[id] = JSON.parse(office[:address], symbolize_names: true)
            end
          end

          # Возвращает ассоциативный массив, в котором идентификаторам карточек
          # сотрудников сопоставлены ассоциативные массивы с информацией о
          # сотрудниках
          # @return [Hash]
          #   результирующий ассоциативный массив
          def employees
            @employees ||= db[:employees].each_with_object({}) do |e, memo|
              memo[e[:id]] = e
            end
          end

          private

          # Возвращает объект, инкапсулирующий работу с базой данных `org_struct`
          # @return [Sequel::Database]
          #   результирущий объект
          def db
            @db ||= connect
          end

          # Создаёт и возвращает объект, инкапсулирующий работу с базой данных
          # `org_struct`
          # @return [Sequel::Database]
          #   результирущий объект
          def connect
            params = {
              adapter:  :postgres,
              host:     ENV['CC_OS_HOST'],
              database: ENV['CC_OS_NAME'],
              user:     ENV['CC_OS_USER'],
              password: ENV['CC_OS_PASS']
            }
            Sequel.connect(params).tap do |db|
              db.loggers << $logger
            end
          end
        end
      end
    end
  end
end
