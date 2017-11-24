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
                  on_update: :cascade,
                  on_delete: :cascade

      column :name,  :text, index: true, null: false
      column :value, :text, index: true

      primary_key %i(case_id name), name: :case_attributes_pk

      constraint :case_attributes_name_exclusions,
                 Sequel.lit('name <> \'type\' AND name <> \'created_at\'')
    end
  end
end
