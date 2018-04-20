# frozen_string_literal: true

require 'set'

require_relative 'case_extractor'

module CaseCore
  module Tasks
    class Transfer
      module CaseManager
        # Класс объектов, предоставляющих возможность извлечения информации о
        # заявках для импорта
        class CasesExtractor
          # Возвращает ассоциативный массив, в котором ключами являются
          # ассоциативные массивы с атрибутами записей заявок в `case_core`, а
          # значениями — ассоциативные массивы с атрибутами записей заявок в
          # `case_manager`
          # @param [CaseCore::Tasks::Transfer::CaseManager::DB] db
          #   объект, предоставляющий доступ к записям заявок в базе данных
          #   `case_manager`
          # @return [Hash]
          #   результирующий ассоциативный массив
          def self.extract(db)
            new(db).extract
          end

          # Инициализирует объект класса
          # @param [CaseCore::Tasks::Transfer::CaseManager::DB] db
          #   объект, предоставляющий доступ к записям заявок в базе данных
          #   `case_manager`
          def initialize(db)
            @db = db
          end

          # Возвращает ассоциативный массив, в котором ключами являются
          # ассоциативные массивы с атрибутами записей заявок в `case_core`, а
          # значениями — ассоциативные массивы с атрибутами записей заявок в
          # `case_manager`
          # @return [Hash]
          #   результирующий ассоциативный массив
          def extract
            db.cases.each_with_object({}) do |cm_case, memo|
              cc_case = extract_case(cm_case)
              memo[cc_case] = cm_case unless cc_case.nil?
            end
          end

          private

          # Объект, предоставляющий доступ к записям заявок в базе данных
          # `case_manager`
          # @return [CaseCore::Tasks::Transfer::CaseManager::DB]
          #   объект, предоставляющий доступ к записям заявок в базе данных
          #   `case_manager`
          attr_reader :db

          # Возвращает множество идентификаторов записей заявок, присутствующих
          # в базе `case_core`
          # @return [Set<String>]
          #   результирующее множество
          def already_imported_ids
            @already_imported_ids ||= Models::Case.select_map(:id).to_set
          end

          # Возвращает ассоциативный массив атрибутов записи заявки, если
          # запись заявки возможно импортировать, или `nil` в противном случае
          # @param [Hash] c4s3
          #   ассоциативный массив с информацией о заявке
          # @return [Hash]
          #   ассоциативный массив атрибутов записи заявки
          # @return [NilClass]
          #   если запись заявки невозможно импортировать
          def extract_case(c4s3)
            CaseExtractor.extract(c4s3, already_imported_ids)
          end
        end
      end
    end
  end
end