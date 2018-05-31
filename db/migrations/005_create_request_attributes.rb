# frozen_string_literal: true

# Создание таблицы записей атрибутов межведомственных запросов, связанных с
# заявкой

Sequel.migration do
  change do
    create_table(:request_attributes) do
      foreign_key :request_id, :requests,
                  null:      false,
                  index:     true,
                  on_update: :cascade,
                  on_delete: :cascade

      column :name,  :text, index: true, null: false
      column :value, :text

      index Sequel.function(:short_value, :value),
            name: :request_attributes_short_value_index

      index Sequel.function(:short_value, :value),
            name:    :request_attributes_short_value_trgm_index,
            type:    :gin,
            opclass: :gin_trgm_ops

      primary_key %i[request_id name], name: :request_attributes_pk

      constraint :case_attributes_name_exclusions,
                 Sequel.expr(name: %w[id case_id created_at]).~
    end
  end
end
