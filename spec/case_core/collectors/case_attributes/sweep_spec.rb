# frozen_string_literal: true

# Тестирование класса объектов, удаляющих записи атрибутов заявок со значением
# `nil`

CaseCore.need 'collectors/case_attributes/sweep'

RSpec.describe CaseCore::Collectors::CaseAttributes::Sweep do
  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:invoke) }
  end

  describe '.invoke' do
    subject { described_class.invoke }

    let!(:case_attribute) { create(:case_attribute) }

    context 'when there are no case attributes with `nil` value' do
      it 'shouldn\'t delete any case attributes' do
        expect { subject }
          .not_to change { CaseCore::Models::CaseAttribute.count }
      end
    end

    context 'when there are case attributes with `nil` value ' do
      let!(:nil_attribute) { create(:case_attribute, value: nil) }
      let(:case_id) { nil_attribute.case_id }
      let(:name) { nil_attribute.name }

      it 'should delete\'em' do
        expect { subject }
          .to change { CaseCore::Models::CaseAttribute[case_id, name] }
          .to(nil)
      end
    end
  end
end
