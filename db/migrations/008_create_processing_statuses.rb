# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Создание таблицы записей статусов обработки сообщений STOMP
#

Sequel.migration do
  change do
    create_enum :processing_status, %i(ok error)

    create_table(:processing_statuses) do
      primary_key :id

      column :message_id,  :text, index: true, unique: true
      column :status,      :processing_status, null: false
      column :headers,     :jsonb, null: false
      column :error_class, :text
      column :error_text,  :text
    end
  end
end
