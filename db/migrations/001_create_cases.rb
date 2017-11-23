# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Создание таблицы записей заявок
#

Sequel.migration do
  change do
    create_table(:cases) do
      primary_key :id

      column :type,       :text,      index: true, null: false
      column :created_at, :timestamp, index: true, null: false
    end
  end
end
