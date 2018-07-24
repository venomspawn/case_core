# frozen_string_literal: true

module CaseCore
  module Tasks
    class Transfer
      module Extractors
        # Класс объектов, предоставляющих возможность извлечения информации о
        # реестрах передаваемой корреспонденции
        class Registers
          # Возвращает список ассоциативных массивов с информацией о
          # реестрах передаваемой корреспонденции
          # @param [CaseCore::Tasks::Transfer::DataHub] hub
          #   объект, предоставляющий доступ к данным
          # @return [Array]
          #   результирующий список
          def self.extract(hub)
            new(hub).extract
          end

          # Инициализирует объект класса
          # @param [CaseCore::Tasks::Transfer::DataHub] hub
          #   объект, предоставляющий доступ к данным
          def initialize(hub)
            @hub = hub
          end

          # Возвращает список ассоциативных массивов с информацией о
          # реестрах передаваемой корреспонденции
          # @return [Array]
          #   результирующий список
          def extract
            hub.cm.registers.each_with_object([]) do |(id, register), memo|
              cases = hub.cm.register_cases[id]
              memo << extract_register(register, cases) unless cases.blank?
            end
          end

          private

          # Объект, предоставляющий доступ к записям заявок в базе данных
          # `case_manager`
          # @return [CaseCore::Tasks::Transfer::DataHub]
          #   объект, предоставляющий доступ к данным
          attr_reader :hub

          # Возвращает ассоциативный массив с импортируемой информацией о
          # реестре передаваемой корреспонденции
          # @param [Hash] register
          #   ассоциативный массив атрибутов записи реестра в `case_manager`
          # @param [Array<String>] cases
          #   список идентиификаторов записей заявок, находящихся в реестре
          # @return [Hash]
          #   результирующий ассоциативный массив
          def extract_register(register, cases)
            register.slice(:institution_rguid, :back_office_id).tap do |result|
              office_id = register[:office_id]
              office = hub.mfc.ld_offices[office_id] || {}
              result[:institution_office_rguid] = office[:rguid]

              result[:type]    = register[:register_type]
              result[:sent]    = register[:exported]
              result[:sent_at] = register[:exported_at]
              result[:cases]   = Oj.dump(cases)
            end
          end
        end
      end
    end
  end
end
