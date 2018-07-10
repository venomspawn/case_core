# frozen_string_literal: true

# Файл тестирования класса действия получения информации о межведомственном
# запросе

RSpec.describe CaseCore::Actions::Requests::Show do
  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:new) }
  end

  describe '.new' do
    subject(:result) { described_class.new(params, rest) }

    let(:params) { { id: id } }
    let(:id) { 1 }
    let(:rest) { nil }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(described_class) }
    end

    it_should_behave_like 'an action parameters receiver',
                          params:          { id: 1 },
                          wrong_structure: {}
  end

  describe 'instance' do
    subject { described_class.new(params) }

    let(:params) { { id: id } }
    let(:id) { 1 }

    it { is_expected.to respond_to(:show) }
  end

  describe '#show' do
    subject(:result) { instance.show }

    let(:instance) { described_class.new(params) }
    let(:params) { { id: id } }

    describe 'result' do
      subject { result }

      let(:c4s3) { create(:case) }
      let(:request) { create(:request, case: c4s3) }
      let!(:request_attr) { create(:request_attribute, *traits) }
      let(:traits) { [request: request, name: 'name', value: 'value'] }
      let(:id) { request.id }

      it { is_expected.to match_json_schema(described_class::RESULT_SCHEMA) }
    end

    context 'when request record can\'t be found by provided id' do
      let(:id) { 100_500 }

      it 'should raise Sequel::NoMatchingRow' do
        expect { subject }.to raise_error(Sequel::NoMatchingRow)
      end
    end
  end
end
