# frozen_string_literal: true

# Файл тестирования функций модуля `CaseCore::Actions::ProcessingStatuses`

RSpec.describe CaseCore::Actions::ProcessingStatuses do
  subject { described_class }

  it { is_expected.to respond_to(:show) }

  describe '.show' do
    subject(:result) { described_class.show(params) }

    let(:params) { { message_id: message_id } }

    describe 'result' do
      subject { result }

      let(:message_id) { processing_status.message_id }
      let(:schema) { described_class::Show::RESULT_SCHEMA }

      context 'when processing status is `ok`' do
        let(:processing_status) { create(:processing_status, status: :ok) }

        it { is_expected.to match_json_schema(schema) }
      end

      context 'when processing status is `error`' do
        let(:processing_status) { create(:processing_status, status: :error) }

        it { is_expected.to match_json_schema(schema) }
      end
    end

    context 'when argument is not of Hash type' do
      let(:params) { 'not of Hash type' }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end

    context 'when argument is of Hash type' do
      context 'when argument doesn\'t have `message_id` attribute' do
        let(:params) { { doesnt: :have_message_id_attribute } }

        it 'should raise JSON::Schema::ValidationError' do
          expect { subject }.to raise_error(JSON::Schema::ValidationError)
        end
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
