# frozen_string_literal: true

module CaseCore
  module Tasks
    class Transfer
      # Пространство имён классов объектов, оперирующих записями из базы данных
      # `case_manager`
      module CaseManager
        # Класс объектов, предоставляющих возможность работы с базой данных
        # `case_manager`
        class DB
          # Возвращает список ассоциативных массивов с информацией о заявках
          # @return [Array<Hash>]
          #   результирующий список
          def cases
            @cases ||= db[:cases].to_a
          end

          private

          # Возвращает объект, инкапсулирующий работу с базой данных
          # `case_manager`
          # @return [Sequel::Database]
          #   результирущий объект
          def db
            @db ||= connect
          end

          # Создаёт и возвращает объект, инкапсулирующий работу с базой данных
          # `case_manager`
          # @return [Sequel::Database]
          #   результирущий объект
          def connect
            params = {
              adapter:  :postgres,
              host:     ENV['CC_CM_HOST'],
              database: ENV['CC_CM_NAME'],
              user:     ENV['CC_CM_USER'],
              password: ENV['CC_CM_PASS']
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