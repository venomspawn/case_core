# frozen_string_literal: true

# Изменение таблицы записей документов, приложенных к заявке, с целью выделения
# информации об электронных копиях документов в отдельную таблицу `scans`

Sequel.migration do
  columns = %i[
    direction
    correct
    provided_as
    size
    last_modified
    quantity
    mime_type
    filename
    in_document_id
    created_at
    fs_id
  ]

  up do
    alter_table(:documents) do
      add_foreign_key :scan_id, :scans,
                      index: true,
                      on_update: :cascade,
                      on_delete: :restrict
    end

    create_scan = proc do |document|
      result = Sequel::Model
               .db[:scans]
               .returning(:id)
               .insert(columns, document.values_at(*columns))
      result.first[:id]
    end

    update_document = proc do |document, scan_id|
      Sequel::Model
        .db[:documents]
        .where(id: document[:id])
        .update(scan_id: scan_id)
    end

    self[:documents].each do |document|
      next if document[:provided].nil? || document[:provided].is_a?(FalseClass)
      next if document[:fs_id].nil?
      scan_id = create_scan[document]
      update_document[document, scan_id]
    end

    alter_table(:documents) do
      drop_column :direction
      drop_column :correct
      drop_column :provided_as
      drop_column :size
      drop_column :last_modified
      drop_column :quantity
      drop_column :mime_type
      drop_column :filename
      drop_column :provided
      drop_column :in_document_id
      drop_column :created_at

      drop_foreign_key :fs_id
    end
  end

  down do
    alter_table(:documents) do
      add_column :direction,      :direction_type, default: 'input'
      add_column :correct,        :boolean
      add_column :provided_as,    :provided_as_type
      add_column :size,           :text
      add_column :last_modified,  :text
      add_column :quantity,       :integer, default: 0
      add_column :mime_type,      :text
      add_column :filename,       :text
      add_column :provided,       :boolean, default: true
      add_column :in_document_id, :text
      add_column :created_at,     :timestamp

      add_foreign_key :fs_id, :files,
                      type:      :uuid,
                      on_delete: :restrict,
                      on_update: :cascade
    end

    document_scan = proc do |id|
      Sequel::Model
        .db[:scans]
        .where(id: id)
        .select(*columns)
        .first
    end

    update_document = proc do |document, values|
      Sequel::Model.db[:documents].where(id: document[:id]).update(values)
    end

    documents =
      Sequel::Model.db[:documents].select(:id, :scan_id).exclude(scan_id: nil)
    documents.each do |document|
      scan = document_scan[document[:scan_id]]
      update_document[document, scan]
    end

    alter_table(:documents) do
      drop_foreign_key :scan_id
    end
  end
end
