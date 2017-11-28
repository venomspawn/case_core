# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Фабрика записей реестров передаваемой корреспонденции
#

FactoryGirl.define do
  factory :register, class: CaseCore::Models::Register do
    institution_rguid { create(:string) }
    office_id         { create(:string) }
    back_office_id    { create(:string) }
    register_type     { create(:enum, values: %w(cases requests)) }
    exported          { create(:boolean) }
    exported_id       { create(:string) }
    exported_at       { Time.now }
  end
end
