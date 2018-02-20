# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Создание таблицы записей атрибутов заявок
#

Sequel.migration do
  change do
    create_table(:case_attributes) do
      foreign_key :case_id, :cases,
                  type:      :text,
                  null:      false,
                  index:     true,
                  on_update: :cascade,
                  on_delete: :cascade

      column :name,  :text, index: true, null: false
      column :value, :text

      primary_key %i(case_id name), name: :case_attributes_pk

      index :value,
            name:  :case_attributes_short_value_index,
            where: Sequel.function(:value_is_short, :value)

      index :value,
            name:    :case_attributes_short_value_trgm_index,
            type:    :gin,
            opclass: :gin_trgm_ops,
            where:   Sequel.function(:value_is_short, :value)

      constraint :case_attributes_name_exclusions,
                 Sequel.expr(name: %w(id type created_at documents)).~
    end
  end
end
