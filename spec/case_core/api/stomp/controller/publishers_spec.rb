# frozen_string_literal: true

# Файл тестирования класса `CaseCore::API::STOMP::Controller::Publishers`
# объектов, отображающих произвольные объекты в объекты, публикующие сообщения
# STOMP

RSpec.describe CaseCore::API::STOMP::Controller::Publishers do
  subject(:instance) { described_class.new }

  describe 'instance' do
    subject { instance }

    it { is_expected.to respond_to(:[]) }
  end

  describe '#[]' do
    subject(:result) { instance[obj] }

    let(:obj) { Object.new }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(CaseCore::API::STOMP::Controller::Publisher) }

      context 'when the same object is used as argument' do
        it 'should be the same' do
          expect(subject).to be == instance[obj]
        end
      end

      context 'when two equal unfrozen strings are used as arguments' do
        let(:obj) { +'abc' }
        let(:str) { +'abc' }

        it 'should not be the same' do
          expect(subject).not_to be == instance[str]
        end
      end
    end
  end
end
