# frozen_string_literal: true

module CaseCore
  need 'helpers/log'
  need 'tasks/transfer/extractors/registers'

  module Tasks
    class Transfer
      module Importers
        # Класс объектов, импортирующих записи реестров передаваемой
        # корреспонденции
        class Registers
          include CaseCore::Helpers::Log

          # Импортирует записи реестров передаваемой корреспонденции
          # @param [CaseCore::Tasks::Transfer::DataHub] hub
          #   объект, предоставляющий доступ к данным
          def self.import(hub)
            new(hub).import
          end

          # Инициализирует объект класса
          # @param [CaseCore::Tasks::Transfer::DataHub] hub
          #   объект, предоставляющий доступ к данным
          def initialize(hub)
            @hub = hub
          end

          # Импортирует записи реестров передаваемой корреспонденции
          def import
            hub.mfc.import_registers(registers)
            log_imported_registers(registers.size, binding)
          end

          private

          # Объект, предоставляющий доступ к данным
          # @return [CaseCore::Tasks::Transfer::DataHub]
          #   объект, предоставляющий доступ к данным
          attr_reader :hub

          # Возвращает список ассоциативных массивов с информацией о реестрах
          # передаваемой корреспонденции
          # @return [Array]
          #   результирующий список
          def registers
            @registers ||= Extractors::Registers.extract(hub)
          end

          # Создаёт запись в журнале событий о том, что импортированы реестры
          # передаваемой корреспонденции
          # @param [Integer] count
          #   количество импортированных реестров
          # @param [Binding] context
          #   контекст
          def log_imported_registers(count, context)
            log_info(context) { <<-MESSAGE }
              Импортированы реестры передаваемой корреспонденции в количестве
              #{count}
            MESSAGE
          end
        end
      end
    end
  end
end
