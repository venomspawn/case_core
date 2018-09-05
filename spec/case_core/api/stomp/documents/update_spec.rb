# frozen_string_literal: true

# Тестирование обновления записи документа с помощью обработчика сообщений
# STOMP в контроллере класса `CaseCore::API::STOMP::Controller`

RSpec.describe CaseCore::API::STOMP::Controller do
  describe 'update of document' do
    include CaseCore::API::STOMP::Controller::Processors::IncomingSpecHelper

    before do
      client = double('stomp-client')
      allow(client).to receive(:subscribe).and_yield(message)
      allow(client).to receive(:join)
      allow(client).to receive(:close)
      allow(Stomp::Client).to receive(:new).and_return(client)

      allow(CaseCore::API::STOMP::Controller.instance).to receive(:sleep)
    end

    subject(:run!) { described_class.run! }

    let(:message) { create(:stomp_message, headers: headers, body: body) }
    let(:headers) { create_incoming_headers(message_id, entities, action) }
    let(:message_id) { 'id' }
    let(:entities) { 'documents' }
    let(:action) { 'update' }
    let(:body) { doc_attrs.to_json }
    let(:doc_attrs) { { id: id, case_id: case_id, size: new_size } }
    let(:case_id) { c4s3.id }
    let(:c4s3) { create(:case) }
    let(:id) { document.id }
    let(:document) { create(:document, traits) }
    let(:traits) { { case: c4s3, scan_id: scan_id, id: 'id' } }
    let(:scan_id) { scan.id }
    let(:scan) { create(:scan, size: old_size) }
    let(:old_size) { 'old_size' }
    let(:new_size) { 'new_size' }
    let(:status_records) { CaseCore::Models::ProcessingStatus }
    let(:status_record) { status_records.where(message_id: message_id).last }
    let(:status) { status_record&.status }

    it 'should update attributes of the scan of the document' do
      expect { subject }
        .to change { scan.reload.size }
        .from(old_size)
        .to(new_size)
    end

    it 'should have `ok` status' do
      subject
      expect(status).to be == 'ok'
    end

    context 'when body is not a JSON-string' do
      let(:body) { 'not a JSON-string' }

      it 'shouldn\'t update attributes of the scan record' do
        expect { subject }.not_to change { scan.reload.size }
      end

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end
    end

    context 'when body is a JSON-string but not of Hash' do
      let(:doc_attrs) { 'not of Hash' }

      it 'shouldn\'t update attributes of the scan record' do
        expect { subject }.not_to change { scan.reload.size }
      end

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end
    end

    context 'when body is a JSON-string of Hash of wrong structure' do
      let(:doc_attrs) { { type: { wrong: :structure } } }

      it 'shouldn\'t update attributes of the scan record' do
        expect { subject }.not_to change { scan.reload.size }
      end

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end
    end

    context 'when case record can\'t be found' do
      let(:case_id) { 'won\'t be found' }

      it 'shouldn\'t update attributes of the scan record' do
        expect { subject }.not_to change { scan.reload.size }
      end

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end
    end

    context 'when document record can\'t be found' do
      let(:id) { 'won\'t be found' }

      it 'shouldn\'t update attributes of the scan record' do
        expect { subject }.not_to change { scan.reload.size }
      end

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end
    end

    context 'when document doesn\'t have a scan' do
      let(:scan_id) { nil }

      it 'shouldn\'t update attributes of the scan record' do
        expect { subject }.not_to change { scan.reload.size }
      end

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end
    end
  end
end
