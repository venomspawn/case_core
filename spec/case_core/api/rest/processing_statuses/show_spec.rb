# frozen_string_literal: true

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования метода REST API, возвращающего информацию о статусе
# обработки сообщения STOMP с заданным значением заголовка `x_message_id`
#

RSpec.describe CaseCore::API::REST::Controller do
  describe 'GET /procesisng_statuses/:message_id' do
    subject { get "/processing_statuses/#{message_id}" }

    let!(:processing_status) { create(:processing_status) }
    let(:message_id) { processing_status.message_id }
    let(:schema) { CaseCore::Actions::ProcessingStatuses::Show::RESULT_SCHEMA }

    it { is_expected.to be_ok }
    it { is_expected.to have_proper_body(schema) }

    context 'when case record can\'t be found by provided id' do
      let(:message_id) { 'won%27t%20be%20found' }

      it { is_expected.to be_not_found }
    end
  end
end
