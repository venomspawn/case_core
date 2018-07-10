# frozen_string_literal: true

# Файл тестирования класса `CaseCore::Actions::Documents::Index` действия
# получения информации о документах, прикреплённых к заявке

RSpec.describe CaseCore::Actions::Documents::Index do
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
                          wrong_structure: { wrong: :structure }
  end

  describe 'instance' do
    subject { described_class.new(params) }

    let(:params) { { id: id } }
    let(:id) { 'id' }

    it { is_expected.to respond_to(:index) }
  end

  describe '#index' do
    subject(:result) { instance.index }

    let(:instance) { described_class.new(params) }
    let(:params) { { id: id } }

    describe 'result' do
      subject { result }

      let!(:c4s3) { create(:case) }
      let!(:documents) { create_list(:document, 2, case: c4s3) }
      let(:id) { c4s3.id }

      it { is_expected.to match_json_schema(described_class::RESULT_SCHEMA) }
    end

    context 'when case record can\'t be found by provided id' do
      let(:id) { 'won\'t be found' }

      it 'should raise Sequel::NoMatchingRow' do
        expect { subject }.to raise_error(Sequel::NoMatchingRow)
      end
    end
  end
end
