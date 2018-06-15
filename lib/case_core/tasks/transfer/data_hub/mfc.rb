# frozen_string_literal: true

require_relative 'base/db'

module CaseCore
  module Tasks
    class Transfer
      class DataHub
        # Класс объектов, предоставляющих возможность работы с базой данных
        # `mfc`
        class MFC < Base::DB
          # Ассоциативный массив, в котором идентификаторам записей операторов
          # `mfc` сопоставлены ассоциативные массивы с информацией об
          # операторах
          # @return [Hash]
          #   ассоциативный массив с информацией об операторах
          attr_reader :ecm_people

          # Ассоциативный массив, в котором RGUID ведомств локального
          # справочника `mfc` сопоставлены ассоциативные массивы с информацией
          # об этих ведомствах
          # @return [Hash]
          #   ассоциативный массив с информацией о ведомствах
          attr_reader :ld_institutions

          # Ассоциативный массив, в котором идентификаторам записей офисов
          # ведомства локального справочника `mfc` сопоставлены ассоциативные
          # массивы с информацией об этих офисах
          # @return [Hash]
          #   ассоциативный массив с информацией об офисах ведомств
          attr_reader :ld_offices

          # Ассоциативный массив, в котором идентификаторам записей офисов
          # ведомств локального справочника `mfc` сопоставлены ассоциативные
          # массивы с информацией об адресах этих офисов
          # @return [Hash]
          #   ассоциативный массив с информацией об адресах
          attr_reader :ld_addresses

          # Ассоциативный массив, в котором идентификаторам записей паспортов
          # услуг локального справочника `mfc` сопоставлены ассоциативные
          # массивы с информацией о паспортах этих услуг
          # @return [Hash]
          #   ассоциативный массив с информацией о паспортах услуг
          attr_reader :ld_passports

          # Ассоциативный массив, в котором идентификаторам записей услуг
          # локального справочника `mfc` сопоставлены ассоциативные массивы с
          # информацией об этих услугах
          # @return [Hash]
          #   ассоциативный массив с информацией об услугах
          attr_reader :ld_services

          # Ассоциативный массив, в котором RGUID записей целей услуг
          # локального справочника `mfc` сопоставлены ассоциативные массивы с
          # информацией о целях этих услуг
          # @return [Hash]
          #   ассоциативный массив с информацией о целях услуг
          attr_reader :ld_target_services

          # Инициализирует объект класса
          def initialize
            settings = DataHub.settings
            host = settings.mfc_host
            name = settings.mfc_name
            user = settings.mfc_user
            pass = settings.mfc_pass
            super(:mysql2, host, name, user, pass)
            initialize_collections
          end

          # Импортирует данные о реестрах передаваемой корреспонденции в базу
          # `mfc`
          # @param [Array<Hash>] registers
          #   список ассоциативных массивов с информацией о реестрах
          #   передаваемой корреспонденции
          def import_registers(registers)
            return if registers.empty?
            columns = registers.first.keys
            values = registers.map { |hash| hash.values_at(*columns) }
            db[:registers].import(columns, values)
          end

          private

          # Инициализирует коллекции данных
          def initialize_collections
            initialize_ecm_people
            initialize_ld_institutions
            initialize_ld_offices
            initialize_ld_addresses
            initialize_ld_passports
            initialize_ld_services
            initialize_ld_target_services
          end

          # Список названий столбцов, извлекаемых из таблицы `ecm_people`
          ECM_PEOPLE_COLUMNS = %i[id org_struct_id].freeze

          # Инициализирует коллекцию данных об учётных записях операторов
          def initialize_ecm_people
            data = db[:ecm_people].select(*ECM_PEOPLE_COLUMNS)
            @ecm_people = data.as_hash(:id)
          end

          # Список названий столбцов, извлекаемых из таблицы `ld_institutions`
          LD_INSTITUTIONS_COLUMNS = %i[rguid title].freeze

          # Инициализирует коллекцию данных о ведомствах локального справочника
          def initialize_ld_institutions
            data = db[:ld_institutions].select(*LD_INSTITUTIONS_COLUMNS)
            @ld_institutions = data.as_hash(:rguid)
          end

          # Список названий столбцов, извлекаемых из таблицы `ld_offices`
          LD_OFFICES_COLUMNS = %i[id title].freeze

          # Инициализирует коллекцию данных об офисах ведомств локального
          # справочника
          def initialize_ld_offices
            data = db[:ld_offices].select(*LD_OFFICES_COLUMNS)
            @ld_offices = data.as_hash(:id)
          end

          # Инициализирует коллекцию данных об адресах офисов локального
          # справочника
          def initialize_ld_addresses
            @ld_addresses = db[:ld_office_addresses].as_hash(:office_id)
            @ld_addresses.each_value(&method(:normalize_address))
          end

          # Дополняет атрибутами ассоциативный массив с информацией об адресе
          # @param [Hash] addr
          #   ассоциативный массив с информацией об адресе
          def normalize_address(addr)
            normalize_region(addr)
            normalize_district(addr)
            normalize_settlement(addr)
          end

          # Дополняет ассоциативный массив с информацией об адресе атрибутом с
          # информацией о субъекте РФ
          # @param [Hash] addr
          #   ассоциативный массив с информацией об адресе
          def normalize_region(addr)
            region = addr[:okrug] || addr[:federal_subject]
            addr[:region] = region unless region.blank?
          end

          # Дополняет ассоциативный массив с информацией об адресе атрибутом с
          # информацией о районе субъекта РФ
          # @param [Hash] addr
          #   ассоциативный массив с информацией об адресе
          def normalize_district(addr)
            district = addr[:town_area] || addr[:area]
            addr[:district] = district unless district.blank?
          end

          # Дополняет ассоциативный массив с информацией об адресе атрибутом с
          # информацией о поселении
          # @param [Hash] addr
          def normalize_settlement(addr)
            settlement = addr[:town] || addr[:city_area]
            addr[:settlement] = settlement unless settlement.blank?
          end

          # Список названий столбцов, извлекаемых из таблицы `ld_passports`
          LD_PASSPORTS_COLUMNS = %i[id rguid full_title].freeze

          # Инициализирует коллекцию данных о паспортах услуг локального
          # справочника
          def initialize_ld_passports
            data = db[:ld_passports].select(*LD_PASSPORTS_COLUMNS)
            @ld_passports = data.as_hash(:id)
          end

          # Список названий столбцов, извлекаемых из таблицы `ld_services`
          LD_SERVICES_COLUMNS = %i[id rguid title passport_id].freeze

          # Инициализирует коллекцию данных об услугах локального справочника
          def initialize_ld_services
            data = db[:ld_services].select(*LD_SERVICES_COLUMNS)
            @ld_services = data.as_hash(:id)
          end

          # Список названий столбцов, извлекаемых из таблицы
          # `ld_target_services`
          LD_TARGET_SERVICES_COLUMNS = %i[rguid title service_id].freeze

          # Инициализирует коллекцию данных о целях услуг локального
          # справочника
          def initialize_ld_target_services
            data = db[:ld_target_services].select(*LD_TARGET_SERVICES_COLUMNS)
            @ld_target_services = data.as_hash(:rguid)
          end
        end
      end
    end
  end
end
