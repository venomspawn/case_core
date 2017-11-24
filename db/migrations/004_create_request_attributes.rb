# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Создание таблицы записей атрибутов межведомственных запросов, связанных с
# заявкой
#

Sequel.migration do
  change do
    create_table(:request_attributes) do
      foreign_key :request_id, :requests,
                  null:      false,
                  on_update: :cascade,
                  on_delete: :cascade

      column :name,  :text, index: true, null: false
      column :value, :text, index: true

      primary_key %i(request_id name), name: :request_attributes_pk

      constraint :request_attributes_name_exclusions,
                 Sequel.lit('name <> \'created_at\'')
    end
  end
end
