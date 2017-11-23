# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Фабрика записей атрибутов заявок
#

FactoryGirl.define do
  factory :case_attribute, class: CaseCore::Models::CaseAttribute do
    case_id { create(:case).id }
    name    { create(:string) }
    value   { create(:string) }
  end
end
