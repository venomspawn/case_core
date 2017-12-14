# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования вызова метода модуля бизнес-логики с записью заявки в
# качестве аргумента с помощью обработчика сообщений STOMP в контроллере класса
# `CaseCore::API::STOMP::Controller`
#

RSpec.describe CaseCore::API::STOMP::Controller do
  describe 'call of logic method' do
    include CaseCore::API::STOMP::Controller::Processors::IncomingSpecHelper

    before do
      client = double('stomp-client')
      allow(client).to receive(:subscribe).and_yield(message)
      allow(client).to receive(:join)
      allow(client).to receive(:close)
      allow(Stomp::Client).to receive(:new).and_return(client)

      allow(CaseCore::API::STOMP::Controller.instance).to receive(:sleep)

      CaseCore::Logic::Loader.settings.dir = dir
      allow(logic).to receive(method_name) unless logic.nil?
    end

    subject(:run!) { described_class.run! }

    let(:message) { create(:stomp_message, headers: headers, body: body) }
    let(:headers) { create_incoming_headers(message_id, entities, action) }
    let(:message_id) { 'id' }
    let(:entities) { 'cases' }
    let(:action) { 'call' }
    let(:body) { call_attrs.to_json }
    let(:call_attrs) { { id: case_id, method: method_name } }
    let(:case_id) { c4s3.id }
    let(:c4s3) { create(:case, type: type) }
    let(:type) { 'test_case' }
    let(:method_name) { 'a_method' }
    let(:dir) { "#{$root}/spec/fixtures/logic" }
    let(:logic) { CaseCore::Logic::Loader.logic(type) }
    let(:status_records) { CaseCore::Models::ProcessingStatus }
    let(:status_record) { status_records.where(message_id: message_id).last }
    let(:status) { status_record&.status }

    it 'should call the method' do
      expect(logic)
        .to receive(method_name)
        .with(instance_of(CaseCore::Models::Case))
      subject
    end

    it 'should have `ok` status' do
      subject
      expect(status).to be == 'ok'
    end

    context 'when body is not a JSON-string' do
      let(:body) { 'not a JSON-string' }

      it 'should not call the method' do
        expect(logic).not_to receive(method_name)
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
        expect(logic).not_to receive(method_name)
        subject
      end

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end
    end

    context 'when body is a JSON-string of Hash of wrong structure' do
      let(:call_attrs) { { wrong: :structure } }

      it 'should not call the method' do
        expect(logic).not_to receive(method_name)
        subject
      end

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end
    end

    context 'when case record can\'t be found' do
      let(:case_id) { 'won\'t be found' }

      it 'should not call the method' do
        expect(logic).not_to receive(method_name)
        subject
      end

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end
    end

    context 'when logic can\'t be found' do
      let(:type) { 'won\'t be found' }

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end
    end

    context 'when method is absent' do
      let(:call_attrs) { { id: case_id, method: absent_method_name } }
      let(:absent_method_name) { 'absent' }

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end
    end

    context 'when an error appears during call' do
      before { allow(logic).to receive(method_name).and_raise('') }

      it 'should have `error` status' do
        subject
        expect(status).to be == 'error'
      end
    end
  end
end
