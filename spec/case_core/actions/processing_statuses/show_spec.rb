# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса `CaseCore::Actions::ProcessingStatuses::Show`
# действий получения информации о статусе обработки сообщения STOMP
#

RSpec.describe CaseCore::Actions::ProcessingStatuses::Show do
  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:new) }
  end

  describe '.new' do
    subject(:result) { described_class.new(params) }

    let(:params) { { message_id: message_id } }
    let(:message_id) { 'id' }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(described_class) }
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
