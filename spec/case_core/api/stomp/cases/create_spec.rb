# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования создания записи заявки с помощью обработчика сообщений
# STOMP в контроллере класса `CaseCore::API::STOMP::Controller`
#

RSpec.describe CaseCore::API::STOMP::Controller do
  describe 'creation of case' do
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
    let(:entities) { 'cases' }
    let(:action) { 'create' }
    let(:body) { case_attrs.to_json }
    let(:case_attrs) { { type: :type } }
    let(:status_records) { CaseCore::Models::ProcessingStatus }
    let(:status_record) { status_records.where(message_id: message_id).last }
    let(:status) { status_record&.status }

    it 'should create a record of `CaseCore::Models::Case` model' do
      expect { subject }.to change { CaseCore::Models::Case.count }.by(1)
    end

    it 'should have `ok` status' do
      subject
      expect(status).to be == 'ok'
    end

    context 'when body is not a JSON-string' do
      let(:body) { 'not a JSON-string' }

      it 'should not create any record of `CaseCore::Models::Case` model' do
        expect { subject }.not_to change { CaseCore::Models::Case.count }
      end

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end
    end

    context 'when body is a JSON-string but not of Hash' do
      let(:case_attrs) { 'not of Hash' }

      it 'should not create any record of `CaseCore::Models::Case` model' do
        expect { subject }.not_to change { CaseCore::Models::Case.count }
      end

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end
    end

    context 'when body is a JSON-string of Hash of wrong structure' do
      let(:case_attrs) { { type: { wrong: :structure } } }

      it 'should not create any record of `CaseCore::Models::Case` model' do
        expect { subject }.not_to change { CaseCore::Models::Case.count }
      end

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end
    end

    context 'when `id` attribute is not specified' do
      it 'should create value of the attribute' do
        expect { subject }.to change { CaseCore::Models::Case.count }.by(1)
      end

      it 'should have `ok` status' do
        subject
        expect(status).to be == 'ok'
      end
    end

    context 'when `id` attribute is specified' do
      let(:case_attrs) { { id: id, type: :type } }
      let(:id) { 'id' }

      context 'when a record with the value exists' do
        let!(:case) { create(:case, id: id, type: :type) }

        it 'should not create any record of `CaseCore::Models::Case` model' do
          expect { subject }.not_to change { CaseCore::Models::Case.count }
        end

        it 'should have `error` status' do
          subject
          expect(status).to be == 'error'
        end
      end

      context 'when a record with the value doesn\'t exist' do
        let(:c4s3) { CaseCore::Models::Case.last }

        it 'should use specified value' do
          subject
          expect(c4s3.id).to be == id
        end

        it 'should have `ok` status' do
          subject
          expect(status).to be == 'ok'
        end
      end
    end

    context 'when there are attributes besides `id` and `type`' do
      let(:case_attrs) { { type: :type, attr1: :value1, attr2: :value2 } }

      it 'should create records of `CaseCore::Models::CaseAttribute` model' do
        expect { subject }
          .to change { CaseCore::Models::CaseAttribute.count }
          .by(2)
      end
    end

    context 'when there are documents linked to the case' do
      let(:case_attrs) { { type: :type, documents: [id: :id] } }

      it 'should create records of `CaseCore::Models::Document` model' do
        expect { subject }.to change { CaseCore::Models::Document.count }.by(1)
      end
    end
  end
end
