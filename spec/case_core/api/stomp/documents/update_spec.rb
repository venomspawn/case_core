# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования обновления записи документа с помощью обработчика сообщений
# STOMP в контроллере класса `CaseCore::API::STOMP::Controller`
#

RSpec.describe CaseCore::API::STOMP::Controller do
  describe 'update of document' do
    include CaseCore::API::STOMP::Controller::ProcessorSpecHelper

    before do
      client = double('stomp-client')
      allow(client).to receive(:subscribe).and_yield(message)
      allow(client).to receive(:join)
      allow(client).to receive(:close)
      allow(Stomp::Client).to receive(:new).and_return(client)
    end

    subject(:run!) { described_class.run! }

    let(:message) { create(:stomp_message, headers: headers, body: body) }
    let(:headers) { create_headers(message_id, entities, action) }
    let(:message_id) { 'id' }
    let(:entities) { 'documents' }
    let(:action) { 'update' }
    let(:body) { document_attrs.to_json }
    let(:document_attrs) { { id: id, case_id: case_id, title: new_title } }
    let(:case_id) { c4s3.id }
    let(:c4s3) { create(:case) }
    let(:id) { document.id }
    let(:document) { create(:document, case: c4s3, title: old_title) }
    let(:old_title) { 'old_title' }
    let(:new_title) { 'new_title' }
    let(:status_records) { CaseCore::Models::ProcessingStatus }
    let(:status_record) { status_records.where(message_id: message_id).last }
    let(:status) { status_record&.status }

    it 'should update attributes of the document record with provided id' do
      expect { subject }
        .to change { document.reload.title }
        .from(old_title)
        .to(new_title)
    end

    it 'should have `ok` status' do
      subject
      expect(status).to be == 'ok'
    end

    context 'when body is not a JSON-string' do
      let(:body) { 'not a JSON-string' }

      it 'shouldn\'t update attributes of the document record' do
        expect { subject }.not_to change { document.reload.title }
      end

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end
    end

    context 'when body is a JSON-string but not of Hash' do
      let(:document_attrs) { 'not of Hash' }

      it 'shouldn\'t update attributes of the document record' do
        expect { subject }.not_to change { document.reload.title }
      end

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end
    end

    context 'when body is a JSON-string of Hash of wrong structure' do
      let(:document_attrs) { { type: { wrong: :structure } } }

      it 'shouldn\'t update attributes of the document record' do
        expect { subject }.not_to change { document.reload.title }
      end

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end
    end

    context 'when case record can\'t be found' do
      let(:case_id) { 'won\'t be found' }

      it 'shouldn\'t update attributes of the document record' do
        expect { subject }.not_to change { document.reload.title }
      end

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end
    end

    context 'when document record can\'t be found' do
      let(:id) { 'won\'t be found' }

      it 'shouldn\'t update attributes of the document record' do
        expect { subject }.not_to change { document.reload.title }
      end

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end
    end
  end
end
