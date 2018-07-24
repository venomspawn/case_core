# frozen_string_literal: true

# Тестирование создания записи заявки с помощью обработчика сообщений
# STOMP в контроллере класса `CaseCore::API::STOMP::Controller`

RSpec.describe CaseCore::API::STOMP::Controller do
  describe 'creation of case record' do
    include CaseCore::API::STOMP::Controller::Processors::IncomingSpecHelper

    before do
      client = double('stomp-client')
      allow(client).to receive(:subscribe).and_yield(message)
      allow(client).to receive(:join)
      allow(client).to receive(:close)
      allow(Stomp::Client).to receive(:new).and_return(client)

      allow(CaseCore::API::STOMP::Controller.instance).to receive(:sleep)

      CaseCore::Logic::Loader.settings.dir = dir
    end

    subject(:run!) { described_class.run! }

    let(:dir) { "#{CaseCore.root}/spec/fixtures/logic" }
    let(:message) { create(:stomp_message, headers: headers, body: body) }
    let(:headers) { create_incoming_headers(message_id, entities, action) }
    let(:message_id) { 'id' }
    let(:entities) { 'cases' }
    let(:action) { 'create' }
    let(:body) { case_attrs.to_json }
    let(:case_attrs) { { type: type, **attrs, **documents } }
    let(:attrs) { {} }
    let(:documents) { {} }
    let(:status_records) { CaseCore::Models::ProcessingStatus }
    let(:status_record) { status_records.where(message_id: message_id).last }
    let(:status) { status_record&.status }

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

    context 'when there is no module of business logic for the case' do
      let(:type) { 'no module for the case' }
      let(:attrs) { { attr1: :value1, attr2: :value2 } }
      let(:documents) { { documents: [{ id: :id }, { id: :id2 }] } }

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end

      it 'shouldn\'t create case records' do
        expect { subject }.not_to change { CaseCore::Models::Case.count }
      end

      it 'shouldn\'t create records of case attributes' do
        expect { subject }
          .not_to change { CaseCore::Models::CaseAttribute.count }
      end

      it 'shouldn\'t create records of documents' do
        expect { subject }.not_to change { CaseCore::Models::Document.count }
      end
    end

    context 'when there is a module of business logic for the case' do
      let(:type) { 'test_case' }

      context 'when the module doesn\'t provide `on_case_creation` function' do
        let(:attrs) { { attr1: :value1, attr2: :value2 } }
        let(:documents) { { documents: [{ id: :id }, { id: :id2 }] } }

        it 'should have `error` status' do
          subject
          expect(status).to be == 'error'
        end

        it 'shouldn\'t create case records' do
          expect { subject }.not_to change { CaseCore::Models::Case.count }
        end

        it 'shouldn\'t create records of case attributes' do
          expect { subject }
            .not_to change { CaseCore::Models::CaseAttribute.count }
        end

        it 'shouldn\'t create records of documents' do
          expect { subject }.not_to change { CaseCore::Models::Document.count }
        end
      end

      context 'when the module provides `on_case_creation` function' do
        before { allow(logic).to receive(:on_case_creation) }

        let(:logic) { CaseCore::Logic::Loader.logic(type) }

        it 'should call the function' do
          expect(logic)
            .to receive(:on_case_creation)
            .with(CaseCore::Models::Case)
          subject
        end

        context 'when the function raises `ArgumentError`' do
          before do
            allow(logic).to receive(:on_case_creation).and_raise(error)
          end

          let(:error) { ArgumentError.new }
          let(:attrs) { { attr1: :value1, attr2: :value2 } }
          let(:documents) { { documents: [{ id: :id }, { id: :id2 }] } }

          it 'should have `error` status' do
            subject
            expect(status).to be == 'error'
          end

          it 'shouldn\'t create case records' do
            expect { subject }.not_to change { CaseCore::Models::Case.count }
          end

          it 'shouldn\'t create records of case attributes' do
            expect { subject }
              .not_to change { CaseCore::Models::CaseAttribute.count }
          end

          it 'shouldn\'t create records of documents' do
            expect { subject }
              .not_to change { CaseCore::Models::Document.count }
          end
        end

        context 'when the function raises other errors' do
          before do
            allow(logic).to receive(:on_case_creation).and_raise(NameError)
          end

          it 'should have `ok` status' do
            subject
            expect(status).to be == 'ok'
          end

          it 'should create a record of `CaseCore::Models::Case` model' do
            expect { subject }.to change { CaseCore::Models::Case.count }.by(1)
          end

          context 'when `id` attribute is not specified' do
            it 'should create value of the attribute' do
              expect { subject }
                .to change { CaseCore::Models::Case.count }
                .by(1)
            end
          end

          context 'when `id` attribute is specified' do
            let(:case_attrs) { { id: id, type: type } }
            let(:id) { 'id' }

            context 'when a record with the value exists' do
              let!(:case) { create(:case, id: :id, type: type) }

              it 'should have `error` status' do
                subject
                expect(status).to be == 'error'
              end
            end

            context 'when a record with the value doesn\'t exist' do
              let(:c4s3) { CaseCore::Models::Case.last }

              it 'should have `ok` status' do
                subject
                expect(status).to be == 'ok'
              end

              it 'should use specified value' do
                subject
                expect(c4s3.id).to be == id
              end
            end
          end

          context 'when there are attributes besides `id` and `type`' do
            let(:attrs) { { attr1: :value1, attr2: :value2 } }

            it 'should create records of case attributes' do
              expect { subject }
                .to change { CaseCore::Models::CaseAttribute.count }
                .by(2)
            end
          end

          context 'when there are documents linked to the case' do
            let(:documents) { { documents: [{ id: :id }, { id: :id2 }] } }

            it 'should create records of documents' do
              expect { subject }
                .to change { CaseCore::Models::Document.count }
                .by(2)
            end
          end
        end

        context 'when the function doesn\'t raise an error' do
          it 'should have `ok` status' do
            subject
            expect(status).to be == 'ok'
          end

          it 'should create a record of `CaseCore::Models::Case` model' do
            expect { subject }.to change { CaseCore::Models::Case.count }.by(1)
          end

          context 'when `id` attribute is not specified' do
            it 'should create value of the attribute' do
              expect { subject }
                .to change { CaseCore::Models::Case.count }
                .by(1)
            end
          end

          context 'when `id` attribute is specified' do
            let(:case_attrs) { { id: id, type: type } }
            let(:id) { 'id' }

            context 'when a record with the value exists' do
              let!(:case) { create(:case, id: :id, type: type) }

              it 'should have `error` status' do
                subject
                expect(status).to be == 'error'
              end
            end

            context 'when a record with the value doesn\'t exist' do
              let(:c4s3) { CaseCore::Models::Case.last }

              it 'should have `ok` status' do
                subject
                expect(status).to be == 'ok'
              end

              it 'should use specified value' do
                subject
                expect(c4s3.id).to be == id
              end
            end
          end

          context 'when there are attributes besides `id` and `type`' do
            let(:attrs) { { attr1: :value1, attr2: :value2 } }

            it 'should create records of case attributes' do
              expect { subject }
                .to change { CaseCore::Models::CaseAttribute.count }
                .by(2)
            end
          end

          context 'when there are documents linked to the case' do
            let(:documents) { { documents: [{ id: :id }, { id: :id2 }] } }

            it 'should create records of documents' do
              expect { subject }
                .to change { CaseCore::Models::Document.count }
                .by(2)
            end
          end
        end
      end
    end
  end
end
