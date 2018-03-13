# frozen_string_literal: true

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Фабрика записей атрибутов межведомственных запросов
#

FactoryGirl.define do
  factory :request_attribute, class: CaseCore::Models::RequestAttribute do
    name       { create(:string) }
    value      { create(:string) }

    association :request
  end
end
