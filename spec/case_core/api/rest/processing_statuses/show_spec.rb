# frozen_string_literal: true

# Тестирование метода REST API, возвращающего информацию о статусе
# обработки сообщения STOMP с заданным значением заголовка `x_message_id`

RSpec.describe CaseCore::API::REST::ProcessingStatuses::Show do
  include described_class::SpecHelper

  describe 'GET /procesisng_statuses/:message_id' do
    subject(:response) { get "/processing_statuses/#{message_id}" }

    describe 'response' do
      subject { response }

      let(:processing_status) { create(:processing_status) }
      let(:message_id) { processing_status.message_id }

      it { is_expected.to be_ok }

      it { is_expected.to have_proper_body(schema) }

      context 'when case record can\'t be found by provided id' do
        let(:message_id) { 'won%27t%20be%20found' }

        it { is_expected.to be_not_found }
      end
    end
  end
end
