# frozen_string_literal: true

# Создание таблицы записей файлов

Sequel.migration do
  change do
    create_table(:files) do
      column :id,         :uuid,      primary_key: true
      column :content,    :bytea
      column :created_at, :timestamp, index: true, null: false
    end
  end
end
