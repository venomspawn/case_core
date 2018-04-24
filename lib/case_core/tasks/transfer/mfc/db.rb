# frozen_string_literal: true

module CaseCore
  module Tasks
    class Transfer
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
            @ecm_people ||= db[:ecm_people].as_hash(:id)
          end

          # Возвращает ассоциативный массив, в котором RGUID ведомств,
          # импортированных в локальный справочник `mfc`, сопоставлены
          # ассоциативные массивы с информацией об этих ведомствах
          # @return [Hash]
          #   результирующий ассоциативный массив
          def ld_institutions
            @ld_institutions ||= db[:ld_institutions].as_hash(:id)
          end

          # Возвращает ассоциативный массив, в котором идентификаторам записей
          # офисов ведомств, импортированных в локальный справочник `mfc`,
          # сопоставлены ассоциативные массивы с информацией об этих офисах
          # @return [Hash]
          #   результирующий ассоциативный массив
          def ld_offices
            @ld_offices ||= db[:ld_offices].as_hash(:id)
          end

          # Возвращает ассоциативный массив, в котором идентификаторам записей
          # офисов ведомств, импортированных в локальный справочник `mfc`,
          # сопоставлены ассоциативные массивы с информацией об адресах этих
          # офисов
          # @return [Hash]
          #   результирующий ассоциативный массив
          def ld_addresses
            @ld_addreses ||= db[:ld_office_addresses].as_hash(:office_id)
          end

          # Возвращает ассоциативный массив, в котором идентификаторам записей
          # паспортов услуг, импортированных в локальный справочник `mfc`,
          # сопоставлены ассоциативные массивы с информацией о паспортах этих
          # услуг
          # @return [Hash]
          #   результирующий ассоциативный массив
          def ld_passports
            @ld_passports ||= db[:ld_passports].as_hash(:id)
          end

          # Возвращает ассоциативный массив, в котором идентификаторам записей
          # услуг, импортированных в локальный справочник `mfc`, сопоставлены
          # ассоциативные массивы с информацией об этих услугах
          # @return [Hash]
          #   результирующий ассоциативный массив
          def ld_services
            @ld_services ||= db[:ld_services].as_hash(:id)
          end

          # Возвращает ассоциативный массив, в котором RGUID записей целей
          # услуг, импортированных в локальный справочник `mfc`, сопоставлены
          # ассоциативные массивы с информацией о целях этих услуг
          # @return [Hash]
          #   результирующий ассоциативный массив
          def ld_target_services
            @ld_target_services ||= db[:ld_target_services].as_hash(:rguid)
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
