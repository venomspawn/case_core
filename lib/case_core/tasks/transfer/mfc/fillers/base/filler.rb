# frozen_string_literal: true

module CaseCore
  module Tasks
    class Transfer
      module MFC
        # Пространство имён классов объектов, заполняющих атрибуты заявки
        module Fillers
          # Пространство имён базовых классов объектов, заполняющих атрибуты
          # заявки
          module Base
            # Базовый класс объектов, заполняющих атрибуты заявки
            class Filler
              # Инициализирует объект класса
              # @param [Hash] record
              #   ассоциативный массив полей записи
              # @param [Hash] memo
              #   ассоциативный массив, в который записываются извлечённые
              #   атрибуты
              def initialize(record, memo)
                @record = record
                @memo = memo
              end

              # Извлекает атрибуты заявки и записывает их в предоставленный
              # ассоциативный массив
              def fill
                names.each do |key, name|
                  value = record[key]
                  memo[name] = value unless value.blank?
                end
              end

              private

              # Ассоциативный массив полей записи
              # @return [Hash]
              #   ассоциативный массив полей записи
              attr_reader :record

              # Ассоциативный массив атрибутов заявки
              # @return [Hash]
              #   ассоциативный массив атрибутов заявки
              attr_reader :memo

              # Возвращает ассоциативный массив, в котором названиям полей
              # записи соответствуют названия атрибутов заявки
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
