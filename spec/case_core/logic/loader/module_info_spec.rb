# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса `CaseCore::Logic::Loader::ModuleInfo` объектов,
# содержащих информацию о загруженных модулях бизнес-логики
#

RSpec.describe CaseCore::Logic::Loader::ModuleInfo do
  let(:instance) { described_class.new(version, logic_module) }
  let(:version) { '0.0.0' }
  let(:logic_module) { Object }

  describe 'instance' do
    subject { instance }

    it { is_expected.to respond_to(:time, :version, :logic_module) }
  end

  describe '#time' do
    subject(:result) { instance.time }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(Time) }

      it 'should be a time of now' do
        expect(subject).to be_within(1).of(Time.now)
      end
    end
  end

  describe '#version' do
    subject(:result) { instance.version }

    describe 'result' do
      subject { result }

      context 'when version is specified as a string during creation' do
        it { is_expected.to be_a(String) }
      end
    end
  end

  describe '#logic_module' do
    subject(:result) { instance.logic_module }

    describe 'result' do
      subject { result }

      context 'when module is specified as an object of Module type' do
        it { is_expected.to be_a(Module) }
      end
    end
  end
end
