# frozen_string_literal: true

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Фабрика записей заявок
#

FactoryGirl.define do
  factory :case, class: CaseCore::Models::Case do
    id         { create(:string) }
    type       { create(:string) }
    created_at { Time.now }
  end

  factory :many_cases, class: Array do
    count { 10_000 }
    types { %w[kilo_case kibi_case mega_case mibi_case giga_case gibi_case] }
    names { %w[state status creator_id killer_id closed_at exported_at] }

    skip_create
    initialize_with do
      case_values = 1.upto(count).map do
        [create(:string), create(:enum, values: types), Time.now]
      end
      case_attr_values = case_values.each_with_object([]) do |values, memo|
        names.each { |name| memo << [values.first, name, create(:string)] }
      end
      model = CaseCore::Models::Case
      attr_model = CaseCore::Models::CaseAttribute
      model.import(model.columns, case_values).tap do
        attr_model.import(attr_model.columns, case_attr_values)
      end
    end
  end

  factory :imported_cases, class: Array do
    data { [] }

    skip_create
    initialize_with do
      model = CaseCore::Models::Case
      case_values, case_attr_values =
        data.each_with_object([[], []]) do |hash, (values, attr_values)|
          hash.symbolize_keys!
          values << hash.values_at(*model.columns)
          hash.except(*model.columns).each do |name, value|
            attr_values << [hash[:id], name.to_s, value]
          end
        end
      attr_model = CaseCore::Models::CaseAttribute
      model.import(model.columns, case_values).tap do
        attr_model.import(attr_model.columns, case_attr_values)
      end
    end
  end
end
