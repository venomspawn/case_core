# frozen_string_literal: true

# Создание таблицы записей с информацией об электронных копиях документов

Sequel.migration do
  change do
    create_table(:scans) do
      primary_key :id

      column :direction,      :direction_type, default: 'input'
      column :correct,        :boolean
      column :provided_as,    :provided_as_type
      column :size,           :text
      column :last_modified,  :text
      column :quantity,       :integer, default: 0
      column :mime_type,      :text
      column :filename,       :text
      column :in_document_id, :text
      column :created_at,     :timestamp

      foreign_key :fs_id, :files,
                  type:      :uuid,
                  null:      false,
                  index:     true,
                  on_delete: :restrict,
                  on_update: :cascade
    end
  end
end
