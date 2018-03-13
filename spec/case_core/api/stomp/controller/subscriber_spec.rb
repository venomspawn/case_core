# frozen_string_literal: true

# Файл тестирования класса `CaseCore::API::STOMP::Controller::Subscriber`
# объектов, осуществляющих подписку на сообщения STOMP

RSpec.describe CaseCore::API::STOMP::Controller::Subscriber do
  subject(:instance) { described_class.new(queue) }

  let(:queue) { 'queue' }
  let(:client) { instance.send(:client) }

  describe 'instance' do
    subject { instance }

    it { is_expected.to respond_to(:subscribe, :unsubscribe) }
  end

  describe '#subscribe' do
    before do
      client = double('stomp-client')
      allow(client).to receive(:subscribe).and_yield(message)
      allow(Stomp::Client).to receive(:new).and_return(client)
    end

    let(:message) { create(:stomp_message) }

    context 'when used without block' do
      subject { instance.subscribe(false) }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when used with block' do
      subject { instance.subscribe(false) {} }

      it 'should subscribe to the queue' do
        expect(client).to receive(:subscribe).with(queue)
        subject
      end

      it 'should yield an object of `Stomp::Message` class' do
        expect { |b| instance.subscribe(false, &b) }
          .to yield_with_args(Stomp::Message)
      end
    end
  end

  describe '#unsubscribe' do
    before do
      client = double('stomp-client')
      allow(client).to receive(:unsubscribe)
      allow(Stomp::Client).to receive(:new).and_return(client)
    end

    subject { instance.unsubscribe }

    it 'should unsubscribe from the queue' do
      expect(client).to receive(:unsubscribe).with(queue)
      subject
    end
  end
end
