# frozen_string_literal: true

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Создание таблицы записей межведомственных запросов, связанных с заявкой
#

Sequel.migration do
  change do
    create_table(:requests) do
      primary_key :id

      column :created_at, :timestamp, index: true, null: false

      foreign_key :case_id, :cases,
                  type:      :text,
                  null:      false,
                  index:     true,
                  on_update: :cascade,
                  on_delete: :cascade
    end
  end
end
