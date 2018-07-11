# frozen_string_literal: true

# Тестирование класса `CaseCore::Actions::ProcessingStatuses::Show`
# действий получения информации о статусе обработки сообщения STOMP

RSpec.describe CaseCore::Actions::ProcessingStatuses::Show do
  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:new) }
  end

  describe '.new' do
    subject(:result) { described_class.new(params, rest) }

    let(:params) { { message_id: message_id } }
    let(:message_id) { 'id' }
    let(:rest) { nil }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(described_class) }
    end

    it_should_behave_like 'an action parameters receiver',
                          params:          { message_id: 'id' },
                          wrong_structure: {}
  end

  describe 'instance' do
    subject { described_class.new(params) }

    let(:params) { { message_id: message_id } }
    let(:message_id) { 'id' }

    it { is_expected.to respond_to(:show) }
  end

  describe '#show' do
    subject(:result) { instance.show }

    let(:instance) { described_class.new(params) }
    let(:params) { { message_id: message_id } }

    describe 'result' do
      subject { result }

      let(:message_id) { processing_status.message_id }

      context 'when processing status is `ok`' do
        let(:processing_status) { create(:processing_status, status: :ok) }

        it { is_expected.to match_json_schema(described_class::RESULT_SCHEMA) }
      end

      context 'when processing status is `error`' do
        let(:processing_status) { create(:processing_status, status: :error) }

        it { is_expected.to match_json_schema(described_class::RESULT_SCHEMA) }
      end
    end

    context 'when status record can\'t be found by provided message id' do
      let(:message_id) { 'won\'t be found' }

      it 'should raise Sequel::NoMatchingRow' do
        expect { subject }.to raise_error(Sequel::NoMatchingRow)
      end
    end
  end
end
