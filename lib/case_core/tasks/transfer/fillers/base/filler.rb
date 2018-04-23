# frozen_string_literal: true

module CaseCore
  module Tasks
    class Transfer
      # Пространство имён классов объектов, заполняющих атрибуты заявки
      module Fillers
        # Пространство имён базовых классов объектов, заполняющих атрибуты
        # заявки
        module Base
          # Базовый класс объектов, заполняющих атрибуты заявки
          class Filler
            # Инициализирует объект класса
            # @param [CaseCore::Tasks::Transfer::DataHub] hub
            #   объект, предоставляющий доступ к данным
            # @param [Hash] c4s3
            #   ассоциативный массив с информацией о заявке
            def initialize(hub, c4s3)
              @record = extract_record(hub, c4s3)
              @c4s3 = c4s3
            end

            # Извлекает атрибуты заявки и записывает их в предоставленный
            # ассоциативный массив
            def fill
              names.each do |key, name|
                value = record[key]
                c4s3[name] = value unless value.blank?
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
            attr_reader :c4s3

            # Ассоциативный массив, в котором названиям атрибутов записи
            # соответствуют названия атрибутов заявки
            NAMES = {}.freeze

            # Возвращает ассоциативный массив {NAMES}
            # @return [Hash]
            #   ассоциативный массив названий полей и атрибутов
            def names
              self.class::NAMES
            end

            # Возвращает ассоциативный массив полей записи
            # @param [CaseCore::Tasks::Transfer::DataHub] _hub
            #   объект, предоставляющий доступ к данным
            # @param [Hash] _c4s3
            #   ассоциативный массив с информацией о заявке
            # @return [Hash]
            #   ассоциативный массив полей записи
            def extract_record(_hub, _c4s3)
              {}
            end
          end
        end
      end
    end
  end
end
