# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса `CaseCore::API::STOMP::Controller::Publishers`
# объектов, отображающих произвольные объекты в объекты, публикующие сообщения
# STOMP
#

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

      context 'when two equal strings are used as arguments' do
        let(:obj) { '123' }

        it 'should not be the same' do
          expect(subject).not_to be == instance['123']
        end
      end
    end
  end
end
