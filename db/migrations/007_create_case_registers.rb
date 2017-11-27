# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Создание таблицы записей связей между заявками и реестрами передаваемой
# корреспондеции
#

Sequel.migration do
  change do
    create_table(:case_registers) do
      foreign_key :case_id, :cases,
                  type:      :text,
                  null:      false,
                  unique:    true,
                  on_update: :cascade,
                  on_delete: :cascade

      foreign_key :register_id, :registers,
                  null:      false,
                  on_update: :cascade,
                  on_delete: :cascade

      primary_key [:case_id, :register_id], name: :registers_pk
    end
  end
end
