# frozen_string_literal: true

# Фабрика записей межведомственных запросов

FactoryBot.define do
  factory :request, class: CaseCore::Models::Request do
    created_at { Time.now }

    association :case
  end
end
