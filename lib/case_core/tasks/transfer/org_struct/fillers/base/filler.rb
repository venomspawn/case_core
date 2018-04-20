# frozen_string_literal: true

module CaseCore
  module Tasks
    class Transfer
      module OrgStruct
        # Пространство имён классов объектов, извлекающих атрибуты заявки из
        # `org_structure`
        module Fillers
          # Пространство имён базовых классов объектов, извлекающих атрибуты
          # заявки из `org_structure`
          module Base
            # Базовый класс объектов, извлекающих атрибуты заявки из
            # `org_structure`
            class Filler
              # Инициализирует объект класса
              # @param [Hash] record
              #   ассоциативный массив полей записи `org_structure`
              # @param [Hash] memo
              #   ассоциативный массив, в который записываются извлечённые
              #   атрибуты
              def initialize(record, memo)
                @record = record
                @memo = memo
              end

              # Извлекает и атрибуты заявки из `org_structure` и записывает их
              # в предоставленный ассоциативный массив
              def fill
                names.each do |key, name|
                  value = record[key]
                  memo[name] = value unless value.blank?
                end
              end

              private

              # Ассоциативный массив полей записи `org_structure`
              # @return [Hash]
              #   ассоциативный массив полей записи `org_structure`
              attr_reader :record

              # Возвращает ассоциативный массив, в котором названиям полей
              # записи `org_structure` соответствуют названия атрибутов заявки
              # @return [Hash]
              #   результирующий ассоциативный массив
              def names
                {}
              end
            end
          end
        end
      end
    end
  end
end
