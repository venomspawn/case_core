# frozen_string_literal: true

# Создание таблицы записей заявок

Sequel.migration do
  change do
    create_table(:cases) do
      column :id,         :text,      primary_key: true
      column :type,       :text,      index: true, null: false
      column :created_at, :timestamp, index: true, null: false
    end
  end
end
