# frozen_string_literal: true

# Фабрика записей атрибутов межведомственных запросов

FactoryGirl.define do
  factory :request_attribute, class: CaseCore::Models::RequestAttribute do
    name       { create(:string) }
    value      { create(:string) }

    association :request
  end
end
