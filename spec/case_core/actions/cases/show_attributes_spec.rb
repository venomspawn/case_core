# frozen_string_literal: true

# Файл тестирования класса действия получения информации об атрибуах заявки,
# кроме тех, что присутствуют непосредственно в записи заявки

RSpec.describe CaseCore::Actions::Cases::ShowAttributes do
  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:new) }
  end

  describe '.new' do
    subject(:result) { described_class.new(params, rest) }

    let(:params) { { id: id } }
    let(:id) { 'id' }
    let(:rest) { nil }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(described_class) }
    end

    it_should_behave_like 'an action parameters receiver',
                          params:          { id: 'id' },
                          wrong_structure: {}
  end

  describe 'instance' do
    subject { described_class.new(params) }

    let(:params) { { id: id } }
    let(:id) { 'id' }

    it { is_expected.to respond_to(:show_attributes) }
  end

  describe '#show_attributes' do
    subject(:result) { instance.show_attributes }

    let(:instance) { described_class.new(params) }
    let(:params) { { id: id } }

    describe 'result' do
      subject { result }

      let(:c4s3) { create(:case) }
      let(:id) { c4s3.id }
      let!(:attribute1) { create(:case_attribute, case: c4s3) }
      let!(:attribute2) { create(:case_attribute, case: c4s3) }
      let(:name1) { attribute1.name.to_sym }
      let(:name2) { attribute2.name.to_sym }
      let(:value1) { attribute1.value }
      let(:value2) { attribute2.value }

      it { is_expected.to be_a(Hash) }
      it { is_expected.to match_json_schema(described_class::RESULT_SCHEMA) }

      describe 'keys' do
        subject { result.keys }

        it { is_expected.to all(be_a(Symbol)) }
      end

      context 'when case record can\'t be found' do
        let(:id) { 'won\'t be found' }

        it { is_expected.to be_empty }
      end

      context 'when `names` parameter is absent`' do
        it 'should extract all attributes' do
          expect(subject).to be == { name1 => value1, name2 => value2 }
        end
      end

      context 'when `names` parameter is nil`' do
        let(:params) { { id: id, names: nil } }

        it 'should extract all attributes' do
          expect(subject).to be == { name1 => value1, name2 => value2 }
        end
      end

      context 'when `names` parameter is empty`' do
        let(:params) { { id: id, names: [] } }

        it { is_expected.to be_empty }
      end

      context 'when `names` parameter specifies attributes`' do
        let(:params) { { id: id, names: [name1] } }

        it 'should extract specified attributes' do
          expect(subject).to be == { name1 => value1 }
        end
      end

      context 'when `names` parameter specifies absent attributes`' do
        let(:params) { { id: id, names: %w[absent] } }

        it { is_expected.to be_empty }
      end
    end
  end
end
