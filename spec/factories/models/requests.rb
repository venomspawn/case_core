# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Фабрика записей межведомственных запросов
#

FactoryGirl.define do
  factory :request, class: CaseCore::Models::Request do
    created_at { Time.now }
    case_id    { create(:case).id }
  end
end
