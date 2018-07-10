# frozen_string_literal: true

# Фабрика записей документов, прикреплённых к заявкам

FactoryBot.define do
  factory :document, class: CaseCore::Models::Document do
    id             { create(:string) }
    title          { create(:string) }
    direction      { create(:enum, values: %w[input output]) }
    correct        { create(:boolean) }
    provided_as    { create(:document_provided_as) }
    size           { create(:string) }
    last_modified  { Time.now.to_s }
    quantity       { create(:string) }
    mime_type      { 'image/jpg' }
    filename       { create(:string) }
    provided       { create(:boolean) }
    in_document_id { create(:string) }
    fs_id          { create(:string) }
    created_at     { Time.now }

    association :case
  end

  factory :document_provided_as, class: String do
    skip_create
    initialize_with do
      create(:enum, values: %w[original copy notarized_copy doc_list])
    end
  end
end
