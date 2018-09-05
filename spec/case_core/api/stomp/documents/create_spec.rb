# frozen_string_literal: true

# Тестирование создания записи документа с помощью обработчика сообщений
# STOMP в контроллере класса `CaseCore::API::STOMP::Controller`

RSpec.describe CaseCore::API::STOMP::Controller do
  describe 'creation of document' do
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
    let(:action) { 'create' }
    let(:body) { doc_attrs.to_json }
    let(:doc_attrs) { { case_id: case_id } }
    let(:case_id) { c4s3.id }
    let(:c4s3) { create(:case) }
    let(:status_records) { CaseCore::Models::ProcessingStatus }
    let(:status_record) { status_records.where(message_id: message_id).last }
    let(:status) { status_record&.status }

    it 'should create a record of `CaseCore::Models::Document`' do
      expect { subject }.to change { CaseCore::Models::Document.count }.by(1)
    end

    it 'should have `ok` status' do
      subject
      expect(status).to be == 'ok'
    end

    context 'when body is not a JSON-string' do
      let(:body) { 'not a JSON-string' }

      it 'should not create any record of `CaseCore::Models::Document`' do
        expect { subject }.not_to change { CaseCore::Models::Document.count }
      end

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end
    end

    context 'when body is a JSON-string but not of Hash' do
      let(:doc_attrs) { 'not of Hash' }

      it 'should not create any record of `CaseCore::Models::Document`' do
        expect { subject }.not_to change { CaseCore::Models::Document.count }
      end

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end
    end

    context 'when body is a JSON-string of Hash of wrong structure' do
      let(:doc_attrs) { { type: { wrong: :structure } } }

      it 'should not create any record of `CaseCore::Models::Document`' do
        expect { subject }.not_to change { CaseCore::Models::Document.count }
      end

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end
    end

    context 'when `id` attribute is not specified' do
      it 'should create value of the attribute' do
        expect { subject }.to change { CaseCore::Models::Document.count }.by(1)
      end

      it 'should have `ok` status' do
        subject
        expect(status).to be == 'ok'
      end
    end

    context 'when `provided` is `true` and `fs_id` is proper' do
      let(:doc_attrs) { { case_id: case_id, provided: true, fs_id: file.id } }
      let(:file) { create(:file) }

      it 'should create record of `CaseCore::Models::Scan` model' do
        expect { subject }.to change { CaseCore::Models::Scan.count }.by(1)
      end

      it 'should have `ok` status' do
        subject
        expect(status).to be == 'ok'
      end
    end

    context 'when `provided` is `false`' do
      let(:doc_attrs) { { case_id: case_id, provided: false, fs_id: file.id } }
      let(:file) { create(:file) }

      it 'shouldn\'t create record of `CaseCore::Models::Scan` model' do
        expect { subject }.to change { CaseCore::Models::Scan.count }.by(0)
      end

      it 'should have `ok` status' do
        subject
        expect(status).to be == 'ok'
      end
    end

    context 'when `provided` is `nil`' do
      let(:doc_attrs) { { case_id: case_id, provided: nil, fs_id: file.id } }
      let(:file) { create(:file) }

      it 'shouldn\'t create record of `CaseCore::Models::Scan` model' do
        expect { subject }.to change { CaseCore::Models::Scan.count }.by(0)
      end

      it 'should have `ok` status' do
        subject
        expect(status).to be == 'ok'
      end
    end

    context 'when `provided` is absent' do
      let(:doc_attrs) { { case_id: case_id, fs_id: file.id } }
      let(:file) { create(:file) }

      it 'shouldn\'t create record of `CaseCore::Models::Scan` model' do
        expect { subject }.to change { CaseCore::Models::Scan.count }.by(0)
      end

      it 'should have `ok` status' do
        subject
        expect(status).to be == 'ok'
      end
    end

    context 'when `fs_id` is absent' do
      let(:doc_attrs) { { case_id: case_id, provided: true } }

      it 'shouldn\'t create record of `CaseCore::Models::Scan` model' do
        expect { subject }.to change { CaseCore::Models::Scan.count }.by(0)
      end

      it 'should have `ok` status' do
        subject
        expect(status).to be == 'ok'
      end
    end

    context 'when `id` attribute is specified' do
      let(:doc_attrs) { { id: id, case_id: case_id, fs_id: fs_id } }
      let(:fs_id) { create(:file).id }
      let(:id) { 'id' }

      context 'when a record with the value exists' do
        let!(:document) { create(:document, id: id, case_id: case_id) }

        it 'should not create any record of `CaseCore::Models::Document`' do
          expect { subject }.not_to change { CaseCore::Models::Document.count }
        end

        it 'should have `error` status' do
          subject
          expect(status).to be == 'error'
        end
      end

      context 'when a record with the value doesn\'t exist' do
        let(:document) { CaseCore::Models::Document.last }

        it 'should use specified value' do
          subject
          expect(document.id).to be == id
        end

        it 'should have `ok` status' do
          subject
          expect(status).to be == 'ok'
        end
      end
    end

    context 'when case record can\'t be found by provided id' do
      let(:case_id) { 'won\'t be found' }

      it 'should not create any record of `CaseCore::Models::Document`' do
        expect { subject }.not_to change { CaseCore::Models::Document.count }
      end

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end
    end
  end
end
