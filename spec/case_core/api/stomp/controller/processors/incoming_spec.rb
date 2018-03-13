# frozen_string_literal: true

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса
# `CaseCore::API::STOMP::Controller::Processors::Incoming`
# обработчиков сообщений STOMP, вызывающих действия
#

RSpec.describe CaseCore::API::STOMP::Controller::Processors::Incoming do
  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:new, :process) }
  end

  describe '.new' do
    subject { described_class.new(message) }

    let(:message) { create(:stomp_message) }

    it { is_expected.to be_a(described_class) }

    context 'when argument is not of `Stomp::Message` type' do
      let(:message) { 'not of `Stomp::Message` type' }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end

  describe '.process' do
    include CaseCore::API::STOMP::Controller::Processors::IncomingSpecHelper

    before do
      CaseCore::Actions::Tests = Module.new
      CaseCore::Actions::Tests.define_singleton_method(:test) { |param| }
    end

    after do
      CaseCore::Actions.send(:remove_const, :Tests)
    end

    subject(:result) { described_class.process(message) }

    let(:message) { create(:stomp_message, headers: headers, body: body) }
    let(:headers) { create_incoming_headers(message_id, entities, action) }
    let(:message_id) { 'id' }
    let(:entities) { 'tests' }
    let(:action) { 'test' }
    let(:body) { {}.to_json }

    describe 'result' do
      subject { result }

      context 'when processing is successful' do
        it { is_expected.to be_truthy }
      end

      context 'when `x_message_id` header is absent' do
        let(:message_id) { nil }

        it { is_expected.to be_falsey }
      end

      context 'when `x_entities` header is absent' do
        let(:entities) { nil }

        it { is_expected.to be_falsey }
      end

      context 'when module can\'t be found by `x_entities` header value' do
        let(:entities) { 'wrong' }

        it { is_expected.to be_falsey }
      end

      context 'when `x_action` header is absent' do
        let(:action) { nil }

        it { is_expected.to be_falsey }
      end

      context 'when body is not a JSON-string' do
        let(:body) { 'not a JSON-string' }

        it { is_expected.to be_falsey }
      end

      context 'when function can\'t be found by `x_action` header value' do
        let(:action) { 'wrong' }

        it { is_expected.to be_falsey }
      end

      context 'when function call raises an error' do
        before do
          CaseCore::Actions::Tests.define_singleton_method(:test) { raise }
        end

        it { is_expected.to be_falsey }
      end
    end

    context 'when argument is not of `Stomp::Message` type' do
      let(:message) { 'not of `Stomp::Message` type' }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    let(:status_records) { CaseCore::Models::ProcessingStatus }
    let(:status_record) { status_records.where(message_id: message_id).last }
    let(:last_status) { status_record&.status }
    let(:last_error_class) { status_record&.error_class }
    let(:last_error_text) { status_record&.error_text }

    context 'when processing is successful' do
      it 'should create record of `CaseCore::Models::ProcessingStatus`' do
        expect { subject }
          .to change { CaseCore::Models::ProcessingStatus.count }
          .by(1)
      end

      it 'should set `ok` status in the created record' do
        subject
        expect(last_status).to be == 'ok'
      end
    end

    context 'when `x_message_id` header is absent' do
      let(:message_id) { nil }

      it 'should create record of `CaseCore::Models::ProcessingStatus`' do
        expect { subject }
          .to change { CaseCore::Models::ProcessingStatus.count }
          .by(1)
      end

      it 'should set `error` status in the created record' do
        subject
        expect(last_status).to be == 'error'
      end

      it 'should set error class information in the created record' do
        subject
        expect(last_error_class).not_to be_nil
      end

      it 'should set error text in the created record' do
        subject
        expect(last_error_text).not_to be_nil
      end
    end

    context 'when `x_entities` header is absent' do
      let(:entities) { nil }

      it 'should create record of `CaseCore::Models::ProcessingStatus`' do
        expect { subject }
          .to change { CaseCore::Models::ProcessingStatus.count }
          .by(1)
      end

      it 'should set `error` status in the created record' do
        subject
        expect(last_status).to be == 'error'
      end

      it 'should set error class information in the created record' do
        subject
        expect(last_error_class).not_to be_nil
      end

      it 'should set error text in the created record' do
        subject
        expect(last_error_text).not_to be_nil
      end
    end

    context 'when module can\'t be found by `x_entities` header value' do
      let(:entities) { 'wrong' }

      it 'should create record of `CaseCore::Models::ProcessingStatus`' do
        expect { subject }
          .to change { CaseCore::Models::ProcessingStatus.count }
          .by(1)
      end

      it 'should set `error` status in the created record' do
        subject
        expect(last_status).to be == 'error'
      end

      it 'should set error class information in the created record' do
        subject
        expect(last_error_class).not_to be_nil
      end

      it 'should set error text in the created record' do
        subject
        expect(last_error_text).not_to be_nil
      end
    end

    context 'when `x_action` header is absent' do
      let(:action) { nil }

      it 'should create record of `CaseCore::Models::ProcessingStatus`' do
        expect { subject }
          .to change { CaseCore::Models::ProcessingStatus.count }
          .by(1)
      end

      it 'should set `error` status in the created record' do
        subject
        expect(last_status).to be == 'error'
      end

      it 'should set error class information in the created record' do
        subject
        expect(last_error_class).not_to be_nil
      end

      it 'should set error text in the created record' do
        subject
        expect(last_error_text).not_to be_nil
      end
    end

    context 'when body is not a JSON-string' do
      let(:body) { 'not a JSON-string' }

      it 'should create record of `CaseCore::Models::ProcessingStatus`' do
        expect { subject }
          .to change { CaseCore::Models::ProcessingStatus.count }
          .by(1)
      end

      it 'should set `error` status in the created record' do
        subject
        expect(last_status).to be == 'error'
      end

      it 'should set error class information in the created record' do
        subject
        expect(last_error_class).not_to be_nil
      end

      it 'should set error text in the created record' do
        subject
        expect(last_error_text).not_to be_nil
      end
    end

    context 'when function can\'t be found by `x_action` header value' do
      let(:action) { 'wrong' }

      it 'should create record of `CaseCore::Models::ProcessingStatus`' do
        expect { subject }
          .to change { CaseCore::Models::ProcessingStatus.count }
          .by(1)
      end

      it 'should set `error` status in the created record' do
        subject
        expect(last_status).to be == 'error'
      end

      it 'should set error class information in the created record' do
        subject
        expect(last_error_class).not_to be_nil
      end

      it 'should set error text in the created record' do
        subject
        expect(last_error_text).not_to be_nil
      end
    end

    context 'when function call raises an error' do
      before do
        CaseCore::Actions::Tests.define_singleton_method(:test) { raise }
      end

      it 'should create record of `CaseCore::Models::ProcessingStatus`' do
        expect { subject }
          .to change { CaseCore::Models::ProcessingStatus.count }
          .by(1)
      end

      it 'should set `error` status in the created record' do
        subject
        expect(last_status).to be == 'error'
      end

      it 'should set error class information in the created record' do
        subject
        expect(last_error_class).not_to be_nil
      end

      it 'should set error text in the created record' do
        subject
        expect(last_error_text).not_to be_nil
      end
    end
  end

  describe 'instance' do
    subject { described_class.new(message) }

    let(:message) { create(:stomp_message) }

    it { is_expected.to respond_to(:process) }
  end

  describe '#process' do
    include CaseCore::API::STOMP::Controller::Processors::IncomingSpecHelper

    before do
      CaseCore::Actions::Tests = Module.new
      CaseCore::Actions::Tests.define_singleton_method(:test) { |param| }
    end

    after do
      CaseCore::Actions.send(:remove_const, :Tests)
    end

    subject(:result) { instance.process }

    let(:instance) { described_class.new(message) }
    let(:message) { create(:stomp_message, headers: headers, body: body) }
    let(:headers) { create_incoming_headers(message_id, entities, action) }
    let(:message_id) { 'id' }
    let(:entities) { 'tests' }
    let(:action) { 'test' }
    let(:body) { {}.to_json }

    describe 'result' do
      subject { result }

      context 'when processing is successful' do
        it { is_expected.to be_truthy }
      end

      context 'when `x_message_id` header is absent' do
        let(:message_id) { nil }

        it { is_expected.to be_falsey }
      end

      context 'when `x_entities` header is absent' do
        let(:entities) { nil }

        it { is_expected.to be_falsey }
      end

      context 'when module can\'t be found by `x_entities` header value' do
        let(:entities) { 'wrong' }

        it { is_expected.to be_falsey }
      end

      context 'when `x_action` header is absent' do
        let(:action) { nil }

        it { is_expected.to be_falsey }
      end

      context 'when body is not a JSON-string' do
        let(:body) { 'not a JSON-string' }

        it { is_expected.to be_falsey }
      end

      context 'when function can\'t be found by `x_action` header value' do
        let(:action) { 'wrong' }

        it { is_expected.to be_falsey }
      end

      context 'when function call raises an error' do
        before do
          CaseCore::Actions::Tests.define_singleton_method(:test) { raise }
        end

        it { is_expected.to be_falsey }
      end
    end

    let(:status_records) { CaseCore::Models::ProcessingStatus }
    let(:status_record) { status_records.where(message_id: message_id).last }
    let(:last_status) { status_record&.status }
    let(:last_error_class) { status_record&.error_class }
    let(:last_error_text) { status_record&.error_text }

    context 'when processing is successful' do
      it 'should create record of `CaseCore::Models::ProcessingStatus`' do
        expect { subject }
          .to change { CaseCore::Models::ProcessingStatus.count }
          .by(1)
      end

      it 'should set `ok` status in the created record' do
        subject
        expect(last_status).to be == 'ok'
      end
    end

    context 'when `x_message_id` header is absent' do
      let(:message_id) { nil }

      it 'should create record of `CaseCore::Models::ProcessingStatus`' do
        expect { subject }
          .to change { CaseCore::Models::ProcessingStatus.count }
          .by(1)
      end

      it 'should set `error` status in the created record' do
        subject
        expect(last_status).to be == 'error'
      end

      it 'should set error class information in the created record' do
        subject
        expect(last_error_class).not_to be_nil
      end

      it 'should set error text in the created record' do
        subject
        expect(last_error_text).not_to be_nil
      end
    end

    context 'when `x_entities` header is absent' do
      let(:entities) { nil }

      it 'should create record of `CaseCore::Models::ProcessingStatus`' do
        expect { subject }
          .to change { CaseCore::Models::ProcessingStatus.count }
          .by(1)
      end

      it 'should set `error` status in the created record' do
        subject
        expect(last_status).to be == 'error'
      end

      it 'should set error class information in the created record' do
        subject
        expect(last_error_class).not_to be_nil
      end

      it 'should set error text in the created record' do
        subject
        expect(last_error_text).not_to be_nil
      end
    end

    context 'when module can\'t be found by `x_entities` header value' do
      let(:entities) { 'wrong' }

      it 'should create record of `CaseCore::Models::ProcessingStatus`' do
        expect { subject }
          .to change { CaseCore::Models::ProcessingStatus.count }
          .by(1)
      end

      it 'should set `error` status in the created record' do
        subject
        expect(last_status).to be == 'error'
      end

      it 'should set error class information in the created record' do
        subject
        expect(last_error_class).not_to be_nil
      end

      it 'should set error text in the created record' do
        subject
        expect(last_error_text).not_to be_nil
      end
    end

    context 'when `x_action` header is absent' do
      let(:action) { nil }

      it 'should create record of `CaseCore::Models::ProcessingStatus`' do
        expect { subject }
          .to change { CaseCore::Models::ProcessingStatus.count }
          .by(1)
      end

      it 'should set `error` status in the created record' do
        subject
        expect(last_status).to be == 'error'
      end

      it 'should set error class information in the created record' do
        subject
        expect(last_error_class).not_to be_nil
      end

      it 'should set error text in the created record' do
        subject
        expect(last_error_text).not_to be_nil
      end
    end

    context 'when body is not a JSON-string' do
      let(:body) { 'not a JSON-string' }

      it 'should create record of `CaseCore::Models::ProcessingStatus`' do
        expect { subject }
          .to change { CaseCore::Models::ProcessingStatus.count }
          .by(1)
      end

      it 'should set `error` status in the created record' do
        subject
        expect(last_status).to be == 'error'
      end

      it 'should set error class information in the created record' do
        subject
        expect(last_error_class).not_to be_nil
      end

      it 'should set error text in the created record' do
        subject
        expect(last_error_text).not_to be_nil
      end
    end

    context 'when function can\'t be found by `x_action` header value' do
      let(:action) { 'wrong' }

      it 'should create record of `CaseCore::Models::ProcessingStatus`' do
        expect { subject }
          .to change { CaseCore::Models::ProcessingStatus.count }
          .by(1)
      end

      it 'should set `error` status in the created record' do
        subject
        expect(last_status).to be == 'error'
      end

      it 'should set error class information in the created record' do
        subject
        expect(last_error_class).not_to be_nil
      end

      it 'should set error text in the created record' do
        subject
        expect(last_error_text).not_to be_nil
      end
    end

    context 'when function call raises an error' do
      before do
        CaseCore::Actions::Tests.define_singleton_method(:test) { raise }
      end

      it 'should create record of `CaseCore::Models::ProcessingStatus`' do
        expect { subject }
          .to change { CaseCore::Models::ProcessingStatus.count }
          .by(1)
      end

      it 'should set `error` status in the created record' do
        subject
        expect(last_status).to be == 'error'
      end

      it 'should set error class information in the created record' do
        subject
        expect(last_error_class).not_to be_nil
      end

      it 'should set error text in the created record' do
        subject
        expect(last_error_text).not_to be_nil
      end
    end
  end
end
