# frozen_string_literal: true

# Создание таблицы записей документов, приложенных к заявке

Sequel.migration do
  change do
    create_enum :direction_type, %i[input output]
    create_enum :provided_as_type, %i[original copy notarized_copy doc_list]

    create_table(:documents) do
      primary_key :id, :text

      foreign_key :case_id, :cases,
                  type:      :text,
                  null:      false,
                  index:     true,
                  on_update: :cascade,
                  on_delete: :cascade

      column :title,          :text
      column :direction,      :direction_type, default: 'input'
      column :correct,        :boolean
      column :provided_as,    :provided_as_type
      column :size,           :text
      column :last_modified,  :text
      column :quantity,       :integer, default: 0
      column :mime_type,      :text
      column :filename,       :text
      column :provided,       :boolean, default: true
      column :in_document_id, :text
      column :fs_id,          :text
      column :created_at,     :timestamp
    end
  end
end
