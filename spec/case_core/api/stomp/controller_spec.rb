# frozen_string_literal: true

# Файл тестирования класса `CaseCore::API::STOMP::Controller` контроллера STOMP

RSpec.describe CaseCore::API::STOMP::Controller do
  subject 'the class' do
    subject { described_class }

    it { is_expected.not_to respond_to(:new) }
    it { is_expected.to respond_to(:instance, :publish, :run!, :subscribe) }
  end

  describe '.new' do
    subject { described_class.new }

    it 'should raise NoMethodError' do
      expect { subject }.to raise_error(NoMethodError)
    end
  end

  describe '.instance' do
    subject(:result) { described_class.instance }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(described_class) }

      it 'should be always the same' do
        expect(result).to be == described_class.instance
      end

      it 'should be the only instance of the class' do
        subject
        expect(ObjectSpace.each_object(described_class) {}).to be == 1
      end
    end
  end

  describe '.publish' do
    before do
      client = double('stomp-client')
      allow(client).to receive(:publish)
      allow(Stomp::Client).to receive(:new).and_return(client)
    end

    after do
      publishers.send(:publishers).delete(Thread.current.object_id)
    end

    subject { described_class.publish(queue, message, params) }

    let(:queue) { 'queue' }
    let(:message) { 'message' }
    let(:params) { { header: 'header' } }
    let(:headers) { { 'x_header' => 'header' } }
    let(:publishers) { described_class.instance.send(:publishers) }
    let(:publisher) { publishers[Thread.current] }
    let(:client) { publisher.send(:client) }

    it 'should publish the message with proper headers' do
      expect(client).to receive(:publish).with(String, message, headers)
      subject
    end

    context 'when `params` argument is not of Hash type' do
      let(:params) { 'not of Hash type' }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end

  describe '.run!' do
    subject { described_class.run! }

    context 'when receives incoming STOMP-message' do
      include CaseCore::API::STOMP::Controller::Processors::IncomingSpecHelper

      before do
        client = double('stomp-client')
        allow(client).to receive(:subscribe).and_yield(message)
        allow(client).to receive(:join)
        allow(client).to receive(:close)
        allow(Stomp::Client).to receive(:new).and_return(client)

        allow(CaseCore::API::STOMP::Controller.instance).to receive(:sleep)
        allow(CaseCore::API::STOMP::Controller.instance)
          .to receive(:subscribe_on_responses)

        CaseCore::Actions::Tests = Module.new
        CaseCore::Actions::Tests.define_singleton_method(:test) { |param| }
      end

      after do
        CaseCore::Actions.send(:remove_const, :Tests)
      end

      let(:message) { create(:stomp_message, headers: headers, body: body) }
      let(:headers) { create_incoming_headers(message_id, entities, action) }
      let(:message_id) { 'id' }
      let(:entities) { 'tests' }
      let(:action) { 'test' }
      let(:body) { {}.to_json }
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

    context 'when receives responding STOMP-message' do
      before do
        client = double('stomp-client')
        allow(client).to receive(:subscribe).and_yield(message)
        allow(client).to receive(:join)
        allow(client).to receive(:close)
        allow(Stomp::Client).to receive(:new).and_return(client)

        allow(described_class.instance).to receive(:sleep)
        allow(described_class.instance).to receive(:subscribe_on_incoming)

        CaseCore::Logic::Loader.settings.dir = dir
      end

      let(:message) { create(:stomp_message) }
      let(:dir) { "#{$root}/spec/fixtures/logic" }
      let(:processor) { described_class::Processors::Response }

      context 'when no logic has the handler' do
        before { test_logic }

        let(:test_logic) { CaseCore::Logic::Loader.logic('test_case') }

        it 'shouldn\'t process the message' do
          expect(processor).to receive(:process).and_return(false)
          subject
        end
      end

      context 'when no logic can process the message' do
        before { allow(test_logic).to receive(handler_name).and_return(false) }

        let(:test_logic) { CaseCore::Logic::Loader.logic('test_case') }
        let(:handler_name) { processor::HANDLER_NAME }

        it 'shouldn\'t process the message' do
          expect(processor).to receive(:process).and_return(false)
          subject
        end
      end

      context 'when no logic can process the message without errors' do
        before { allow(test_logic).to receive(handler_name).and_raise('') }

        let(:test_logic) { CaseCore::Logic::Loader.logic('test_case') }
        let(:handler_name) { processor::HANDLER_NAME }

        it 'shouldn\'t process the message' do
          expect(processor).to receive(:process).and_return(false)
          subject
        end
      end

      context 'when there is a logic able to process' do
        before { allow(test_logic).to receive(handler_name).and_return(true) }

        let(:test_logic) { CaseCore::Logic::Loader.logic('test_case') }
        let(:handler_name) { processor::HANDLER_NAME }

        it 'should process the message' do
          expect(processor).to receive(:process).and_return(true)
          subject
        end
      end
    end
  end

  describe '.subscribe' do
    before do
      client = double('stomp-client')
      allow(client).to receive(:subscribe).and_yield(message)
      allow(Stomp::Client).to receive(:new).and_return(client)
    end

    subject(:result) { described_class.subscribe(queue, false) {} }

    let(:queue) { 'queue' }
    let(:message) { create(:stomp_message) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(CaseCore::API::STOMP::Controller::Subscriber) }
    end

    context 'when used without block' do
      subject { described_class.subscribe(queue, false) }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when used with block' do
      subject { described_class.subscribe(queue, false) {} }

      let(:client) { result.send(:client) }

      it 'should subscribe to the queue' do
        expect(client).to receive(:subscribe).with(queue)
        subject
      end

      it 'should yield an object of `Stomp::Message` class' do
        expect { |b| described_class.subscribe(queue, false, &b) }
          .to yield_with_args(Stomp::Message)
      end
    end
  end

  describe 'instance' do
    subject { described_class.instance }

    it { is_expected.to respond_to(:publish, :run!, :subscribe) }
  end

  describe '#publish' do
    before do
      client = double('stomp-client')
      allow(client).to receive(:publish)
      allow(Stomp::Client).to receive(:new).and_return(client)
    end

    subject { instance.publish(queue, message, params) }

    let(:instance) { described_class.instance }
    let(:queue) { 'queue' }
    let(:message) { 'message' }
    let(:params) { { header: 'header' } }
    let(:headers) { { 'x_header' => 'header' } }
    let(:publishers) { instance.send(:publishers) }
    let(:publisher) { publishers[Thread.current] }
    let(:client) { publisher.send(:client) }

    it 'should publish the message with proper headers' do
      expect(client).to receive(:publish).with(String, message, headers)
      subject
    end

    context 'when `params` argument is not of Hash type' do
      let(:params) { 'not of Hash type' }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#run!' do
    subject { instance.run! }

    let(:instance) { described_class.instance }

    context 'when receives incoming STOMP-message' do
      include CaseCore::API::STOMP::Controller::Processors::IncomingSpecHelper

      before do
        client = double('stomp-client')
        allow(client).to receive(:subscribe).and_yield(message)
        allow(client).to receive(:join)
        allow(client).to receive(:close)
        allow(Stomp::Client).to receive(:new).and_return(client)

        allow(CaseCore::API::STOMP::Controller.instance).to receive(:sleep)
        allow(CaseCore::API::STOMP::Controller.instance)
          .to receive(:subscribe_on_responses)

        CaseCore::Actions::Tests = Module.new
        CaseCore::Actions::Tests.define_singleton_method(:test) { |param| }
      end

      after do
        CaseCore::Actions.send(:remove_const, :Tests)
      end

      let(:message) { create(:stomp_message, headers: headers, body: body) }
      let(:headers) { create_incoming_headers(message_id, entities, action) }
      let(:message_id) { 'id' }
      let(:entities) { 'tests' }
      let(:action) { 'test' }
      let(:body) { {}.to_json }
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

    context 'when receives responding STOMP-message' do
      before do
        client = double('stomp-client')
        allow(client).to receive(:subscribe).and_yield(message)
        allow(client).to receive(:join)
        allow(client).to receive(:close)
        allow(Stomp::Client).to receive(:new).and_return(client)

        allow(described_class.instance).to receive(:sleep)
        allow(described_class.instance).to receive(:subscribe_on_incoming)

        CaseCore::Logic::Loader.settings.dir = dir
      end

      let(:message) { create(:stomp_message) }
      let(:dir) { "#{$root}/spec/fixtures/logic" }
      let(:processor) { described_class::Processors::Response }

      context 'when no logic has the handler' do
        before { test_logic }

        let(:test_logic) { CaseCore::Logic::Loader.logic('test_case') }

        it 'shouldn\'t process the message' do
          expect(processor).to receive(:process).and_return(false)
          subject
        end
      end

      context 'when no logic can process the message' do
        before { allow(test_logic).to receive(handler_name).and_return(false) }

        let(:test_logic) { CaseCore::Logic::Loader.logic('test_case') }
        let(:handler_name) { processor::HANDLER_NAME }

        it 'shouldn\'t process the message' do
          expect(processor).to receive(:process).and_return(false)
          subject
        end
      end

      context 'when no logic can process the message without errors' do
        before { allow(test_logic).to receive(handler_name).and_raise('') }

        let(:test_logic) { CaseCore::Logic::Loader.logic('test_case') }
        let(:handler_name) { processor::HANDLER_NAME }

        it 'shouldn\'t process the message' do
          expect(processor).to receive(:process).and_return(false)
          subject
        end
      end

      context 'when there is a logic able to process' do
        before { allow(test_logic).to receive(handler_name).and_return(true) }

        let(:test_logic) { CaseCore::Logic::Loader.logic('test_case') }
        let(:handler_name) { processor::HANDLER_NAME }

        it 'should process the message' do
          expect(processor).to receive(:process).and_return(true)
          subject
        end
      end
    end
  end

  describe '#subscribe' do
    before do
      client = double('stomp-client')
      allow(client).to receive(:subscribe).and_yield(message)
      allow(Stomp::Client).to receive(:new).and_return(client)
    end

    subject(:result) { instance.subscribe(queue, false) {} }

    let(:instance) { described_class.instance }
    let(:queue) { 'queue' }
    let(:message) { create(:stomp_message) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(CaseCore::API::STOMP::Controller::Subscriber) }
    end

    context 'when used without block' do
      subject { instance.subscribe(queue, false) }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when used with block' do
      subject { instance.subscribe(queue, false) {} }

      let(:client) { result.send(:client) }

      it 'should subscribe to the queue' do
        expect(client).to receive(:subscribe).with(queue)
        subject
      end

      it 'should yield an object of `Stomp::Message` class' do
        expect { |b| instance.subscribe(queue, false, &b) }
          .to yield_with_args(Stomp::Message)
      end
    end
  end
end
