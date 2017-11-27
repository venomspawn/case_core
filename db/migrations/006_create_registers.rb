# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Создание таблицы записей реестров передаваемой документации
#

Sequel.migration do
  change do
    create_enum :register_type, %i(cases requests)

    create_table(:registers) do
      primary_key :id

      column :institution_rguid, :text,          index: true
      column :office_id,         :text,          index: true
      column :back_office_id,    :text,          index: true
      column :register_type,     :register_type, index: true
      column :exported,          :boolean
      column :exported_id,       :text
      column :exported_at,       :timestamp
    end
  end
end
