# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Фабрика записей атрибутов заявок
#

FactoryGirl.define do
  factory :case_attribute, class: CaseCore::Models::CaseAttribute do
    name    { create(:string) }
    value   { create(:string) }

    association :case
  end

  factory :case_attributes, class: Array do
    skip_create
    initialize_with do
      c4s3 = attributes[:case]
      attributes.except(:case).map do |(name, value)|
        create(:case_attribute, case: c4s3, name: name.to_s, value: value)
      end
    end
  end
end
