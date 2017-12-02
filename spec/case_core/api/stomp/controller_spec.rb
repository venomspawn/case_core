# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса `CaseCore::API::STOMP::Controller` контроллера STOMP
#

RSpec.describe CaseCore::API::STOMP::Controller do
  subject 'the class' do
    subject { described_class }

    it { is_expected.not_to respond_to(:new) }
    it { is_expected.to respond_to(:instance, :publish, :subscribe) }
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

    it { is_expected.to respond_to(:publish, :subscribe) }
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
