# frozen_string_literal: true

require_relative 'mfc/db'

Dir["#{__dir__}/mfc/fillers/*.rb"].each(&method(:require))

module CaseCore
  module Tasks
    class Transfer
      # Пространство имён классов объектов, оперирующих записями базы данных
      # `mfc`
      module MFC
        # Список классов объектов, заполняющих атрибуты заявки
        FILLER_CLASSES = Fillers
                         .constants
                         .map(&Fillers.method(:const_get))
                         .select { |c| c.is_a?(Class) }
                         .freeze

        # Заполняет ассоциативный массив атрибутами заявки
        # @param [CaseCore::Tasks::Transfer::CaseManager::DB] cm_db
        #   объект, предоставляющий доступ к `case_manager`
        # @param [CaseCore::Tasks::Transfer::MFC::DB] mfc_db
        #   объект, предоставляющий доступ к `mfc`
        # @param [Hash] c4s3
        #   ассоциативный массив с информацией о заявке
        # @param [Hash] memo
        #   ассоциативный массив атрибутов заявки
        def self.fill(cm_db, mfc_db, c4s3, memo)
          FILLER_CLASSES.each do |filler_class|
            filler_class.new(cm_db, mfc_db, c4s3, memo).fill
          end
        end
      end
    end
  end
end
