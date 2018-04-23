# frozen_string_literal: true

require_relative 'org_struct/db'

Dir["#{__dir__}/org_struct/fillers/*.rb"].each(&method(:require))

module CaseCore
  module Tasks
    class Transfer
      module OrgStruct
        # Список классов объектов, извлекающих атрибуты заявки из `org_struct`
        FILLER_CLASSES = Fillers
                         .constants
                         .map(&Fillers.method(:const_get))
                         .select { |c| c.is_a?(Class) }
                         .freeze

        # Заполняет ассоциативный массив атрибутами заявки, извлечённых из
        # `org_struct`
        # @param [CaseCore::Tasks::Transfer::OrgStruct::DB] os_db
        #   объект, предоставляющий доступ к `org_struct`
        # @param [CaseCore::Tasks::Transfer::MFC::DB] mfc_db
        #   объект, предоставляющий доступ к `mfc`
        # @param [Hash] c4s3
        #   ассоциативный массив с информацией о заявке
        # @param [Hash] memo
        #   ассоциативный массив атрибутов заявки
        def self.fill(os_db, mfc_db, c4s3, memo)
          FILLER_CLASSES.each do |filler_class|
            filler_class.new(os_db, mfc_db, c4s3, memo).fill
          end
        end
      end
    end
  end
end
