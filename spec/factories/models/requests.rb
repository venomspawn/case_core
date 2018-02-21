# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Фабрика записей межведомственных запросов
#

FactoryGirl.define do
  factory :request, class: CaseCore::Models::Request do
    created_at { Time.now }

    association :case
  end

  factory :imported_requests, class: Array do
    case_id { create(:case).id }
    data    { [] }

    skip_create
    initialize_with do
      model = CaseCore::Models::Request
      case_values, case_attr_values =
        data.each_with_object([[], []]) do |hash, (values, attr_values)|
          hash.symbolize_keys!
          hash[:case_id] = case_id
          values << hash.values_at(*model.columns)
          hash.except(*model.columns).each do |name, value|
            attr_values << [hash[:id], name.to_s, value]
          end
        end
      attr_model = CaseCore::Models::RequestAttribute
      model.import(model.columns, case_values).tap do
        attr_model.import(attr_model.columns, case_attr_values)
      end
    end
  end
end
