# frozen_string_literal: true

# Фабрика записей статусов обработки сообщений STOMP

FactoryGirl.define do
  factory :processing_status, class: CaseCore::Models::ProcessingStatus do
    message_id  { create(:string) }
    status      { create(:enum, values: %w[ok error]) }
    headers     { {}.pg_json }
    error_class { create(:string) if status.to_s == 'error' }
    error_text  { create(:string) if status.to_s == 'error' }
  end
end
