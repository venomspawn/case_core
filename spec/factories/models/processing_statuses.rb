# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Фабрика записей статусов обработки сообщений STOMP
#

FactoryGirl.define do
  factory :processing_status, class: CaseCore::Models::ProcessingStatus do
    message_id  { create(:string) }
    status      { create(:enum, values: %w(ok error)) }
    headers     { {}.pg_json }
    error_class { create(:string) if status == 'error' }
    error_text  { create(:string) if status == 'error' }
  end
end
