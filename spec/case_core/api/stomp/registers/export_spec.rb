# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования вызова функции `export_register` модуля бизнес-логики с
# записью реестра передаваемой корреспонденции в качестве аргумента с помощью i
# обработчика сообщений STOMP в контроллере класса
# `CaseCore::API::STOMP::Controller`
#

RSpec.describe CaseCore::API::STOMP::Controller do
  describe 'call of `export_register` function of logic' do
    include CaseCore::API::STOMP::Controller::Processors::IncomingSpecHelper

    before do
      client = double('stomp-client')
      allow(client).to receive(:subscribe).and_yield(message)
      allow(client).to receive(:join)
      allow(client).to receive(:close)
      allow(Stomp::Client).to receive(:new).and_return(client)

      allow(CaseCore::API::STOMP::Controller.instance).to receive(:sleep)

      CaseCore::Logic::Loader.settings.dir = dir
      allow(logic).to receive(:export_register) unless logic.nil?
    end

    subject(:run!) { described_class.run! }

    let(:message) { create(:stomp_message, headers: headers, body: body) }
    let(:headers) { create_incoming_headers(message_id, entities, action) }
    let(:message_id) { 'id' }
    let(:entities) { 'registers' }
    let(:action) { 'export' }
    let(:body) { call_attrs.to_json }
    let(:call_attrs) { { id: id } }
    let(:id) { register.id }
    let(:register) { create(:register) }
    let(:c4s3) { create(:case, type: type) }
    let!(:link) { create(:case_register, case: c4s3, register: register) }
    let(:type) { 'test_case' }
    let(:dir) { "#{$root}/spec/fixtures/logic" }
    let(:logic) { CaseCore::Logic::Loader.logic(type) }
    let(:status_records) { CaseCore::Models::ProcessingStatus }
    let(:status_record) { status_records.where(message_id: message_id).last }
    let(:status) { status_record&.status }

    it 'should call `export_register` function' do
      expect(logic)
        .to receive(:export_register)
        .with(instance_of(CaseCore::Models::Register))
      subject
    end

    it 'should have `ok` status' do
      subject
      expect(status).to be == 'ok'
    end

    context 'when arguments are provided' do
      let(:call_attrs) { { id: id, arguments: arguments } }
      let(:arguments) { [a: 'b'] }

      it 'should call `export_register` function with the arguments' do
        expect(logic)
          .to receive(:export_register)
          .with(instance_of(CaseCore::Models::Register), *arguments)
        subject
      end

      it 'should have `ok` status' do
        subject
        expect(status).to be == 'ok'
      end
    end

    context 'when body is not a JSON-string' do
      let(:body) { 'not a JSON-string' }

      it 'should not call the method' do
        expect(logic).not_to receive(:export_register)
        subject
      end

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end
    end

    context 'when body is a JSON-string but not of Hash' do
      let(:call_attrs) { 'not of Hash' }

      it 'should not call the method' do
        expect(logic).not_to receive(:export_register)
        subject
      end

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end
    end

    context 'when `id` parameter is absent' do
      let(:call_attrs) { {} }

      it 'should not call the method' do
        expect(logic).not_to receive(:export_register)
        subject
      end

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end
    end

    context 'when `arguments` parameter is not of Array type' do
      let(:call_attrs) { { id: 1, arguments: 'not of Array type' } }

      it 'should not call the method' do
        expect(logic).not_to receive(:export_register)
        subject
      end

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end
    end

    context 'when a parameter beside `id` and `arguments` is present' do
      let(:call_attrs) { { id: id, a: :parameter } }

      it 'should not call the method' do
        expect(logic).not_to receive(:export_register)
        subject
      end

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end
    end

    context 'when register is empty' do
      let!(:link) {}

      it 'should not call the method' do
        expect(logic).not_to receive(:export_register)
        subject
      end

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end
    end

    context 'when logic can\'t be found by first case' do
      let(:c4s3) { create(:case, type: 'wrong') }

      it 'should not call the method' do
        expect(logic).not_to receive(:export_register)
        subject
      end

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end
    end

    context 'when logic doesn\'t provide `export_register` method' do
      before do
        allow(logic).to receive(:export_register).and_raise(NoMethodError)
      end

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end
    end

    context 'when an error appears during call' do
      before { allow(logic).to receive(:export_register).and_raise('') }

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end
    end
  end
end
