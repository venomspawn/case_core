# frozen_string_literal: true

# Изменение таблицы записей документов, приложенных к заявке, с целью
# выставления внешнего ключа к таблице файлов

Sequel.migration do
  up do
    alter_table(:documents) do
      set_column_type :fs_id, :uuid, using: 'fs_id::uuid'

      add_foreign_key [:fs_id], :files,
                      name:      :documents_fs_id_fkey,
                      on_delete: :restrict,
                      on_update: :cascade
    end
  end

  down do
    alter_table(:documents) do
      drop_foreign_key [:fs_id], name: :documents_fs_id_fkey

      set_column_type :fs_id, :text, using: 'fs_id::text'
    end
  end
end
