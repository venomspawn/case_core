# frozen_string_literal: true

# Фабрика записей документов, прикреплённых к заявкам

FactoryBot.define do
  factory :document, class: CaseCore::Models::Document do
    id    { create(:string) }
    title { create(:string) }

    trait :with_scan do
      scan_id { create(:scan).id }
    end

    association :case
  end
end
