# frozen_string_literal: true

# Тестирование класса объектов, удаляющих записи атрибутов межведомственных
# запросов со значением `nil`

CaseCore.need 'collectors/request_attributes/sweep'

RSpec.describe CaseCore::Collectors::RequestAttributes::Sweep do
  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:invoke) }
  end

  describe '.invoke' do
    subject { described_class.invoke }

    let!(:request_attribute) { create(:request_attribute) }

    context 'when there are no request attributes with `nil` value' do
      it 'shouldn\'t delete any request attributes' do
        expect { subject }
          .not_to change { CaseCore::Models::RequestAttribute.count }
      end
    end

    context 'when there are request attributes with `nil` value ' do
      let!(:nil_attribute) { create(:request_attribute, value: nil) }
      let(:request_id) { nil_attribute.request_id }
      let(:name) { nil_attribute.name }

      it 'should delete\'em' do
        expect { subject }
          .to change { CaseCore::Models::RequestAttribute[request_id, name] }
          .to(nil)
      end
    end
  end
end
