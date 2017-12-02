# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса `CaseCore::API::STOMP::Controller::Publisher`
# объектов, публикующих сообщения STOMP
#

RSpec.describe CaseCore::API::STOMP::Controller::Publisher do
  subject(:instance) { described_class.new }

  describe 'instance' do
    subject { instance }

    it { is_expected.to respond_to(:publish) }
  end

  describe '#publish' do
    before do
      client = double('stomp-client')
      allow(client).to receive(:publish)
      allow(Stomp::Client).to receive(:new).and_return(client)
    end

    subject { instance.publish(queue, message, params) }

    let(:queue) { 'queue' }
    let(:message) { 'message' }
    let(:params) { { header: 'header' } }
    let(:headers) { { 'x_header' => 'header' } }
    let(:client) { instance.send(:client) }

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
end
