# frozen_string_literal: true

module CaseCore
  module Tasks
    class Transfer
      # Пространство имён классов объектов, оперирующих записями базы данных
      # `mfc`
      module MFC
        # Класс объектов, предоставляющих возможность работы с базой данных
        # `mfc`
        class DB
          # Возвращает ассоциативный массив, в котором идентификаторам записей
          # сотрудников в `mfc` сопоставлены ассоциативные массивы с
          # информацией о записях
          # @return [Hash]
          #   результирующий ассоциативный массив
          def ecm_people
            @ecm_people ||= db[:ecm_people].each_with_object({}) do |p, memo|
              memo[p[:id]] = p
            end
          end

          private

          # Возвращает объект, инкапсулирующий работу с базой данных `mfc`
          # @return [Sequel::Database]
          #   результирущий объект
          def db
            @db ||= connect
          end

          # Создаёт и возвращает объект, инкапсулирующий работу с базой данных
          # `mfc`
          # @return [Sequel::Database]
          #   результирущий объект
          def connect
            params = {
              adapter:  :mysql2,
              host:     ENV['CC_MFC_HOST'],
              database: ENV['CC_MFC_NAME'],
              user:     ENV['CC_MFC_USER'],
              password: ENV['CC_MFC_PASS']
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
