# frozen_string_literal: true

# Тестирование класса действия получения информации о заявке

RSpec.describe CaseCore::Actions::Cases::Show do
  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:new) }
  end

  describe '.new' do
    subject(:result) { described_class.new(params, rest) }

    let(:params) { { id: id, names: names } }
    let(:id) { 'id' }
    let(:names) { nil }
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

    let(:params) { { id: id, names: names } }
    let(:id) { 'id' }
    let(:names) { nil }

    it { is_expected.to respond_to(:show) }
  end

  describe '#show' do
    subject(:result) { instance.show }

    let(:instance) { described_class.new(params) }
    let(:params) { { id: id, names: names } }
    let(:names) { nil }

    describe 'result' do
      subject { result }

      let!(:c4s3) { create(:case) }
      let!(:case_attribute) { create(:case_attribute, *args) }
      let(:args) { [case_id: c4s3.id, name: 'attr', value: 'value'] }
      let(:id) { c4s3.id }

      it { is_expected.to match_json_schema(described_class::RESULT_SCHEMA) }

      context 'when names parameter is absent' do
        let(:params) { { id: id } }

        it 'should contain all attributes' do
          expect(result.keys).to match_array %i[id type created_at attr]
        end
      end

      context 'when names parameter is nil' do
        let(:params) { { id: id, names: nil } }

        it 'should contain all attributes' do
          expect(result.keys).to match_array %i[id type created_at attr]
        end
      end

      context 'when names parameter is a list' do
        context 'when the list is empty' do
          let(:params) { { id: id, names: [] } }

          it 'should contain only case fields' do
            expect(result.keys).to match_array %i[id type created_at]
          end
        end

        context 'when the list contains case attribute name' do
          let(:params) { { id: id, names: %w[attr] } }

          it 'should contain the attribute' do
            expect(result.keys).to match_array %i[id type created_at attr]
          end
        end

        context 'when the list contains unknown name' do
          let(:params) { { id: id, names: %w[unknown] } }

          it 'should be a\'ight' do
            expect(result.keys).to match_array %i[id type created_at]
          end
        end
      end
    end

    context 'when case record can\'t be found by provided id' do
      let(:id) { 'won\'t be found' }

      it 'should raise Sequel::NoMatchingRow' do
        expect { subject }.to raise_error(Sequel::NoMatchingRow)
      end
    end
  end
end
