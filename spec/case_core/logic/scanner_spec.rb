# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса `CaseCore::Logic::Scanner` объектов, сканирующих
# директорию с распакованными библиотеками бизнес-логики
#

RSpec.describe CaseCore::Logic::Scanner do
  subject 'the class' do
    subject { described_class }

    it { is_expected.not_to respond_to(:new) }
    it { is_expected.to respond_to(:instance, :run!, :stop!, :running?) }
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

  describe '.run!' do
    after { described_class.stop! }
    before { described_class.stop! }

    subject { described_class.run! }

    let(:instance) { described_class.instance }

    context 'when scanning is not running' do
      it 'should start scanning' do
        expect { subject }.to change { instance.send(:scanner) }.from(nil)
      end

      it 'should invoke `scan` method at least once' do
        expect(instance).to receive(:scan)
        subject
        sleep(0.5)
      end
    end

    context 'when scanning is running' do
      before { described_class.run! }

      it 'shouldn\'t do anything' do
        expect { subject }.not_to change { instance.send(:scanner) }
      end
    end
  end

  describe '.stop!' do
    subject { described_class.stop! }

    let(:instance) { described_class.instance }

    context 'when scanning is not running' do
      it 'shouldn\'t do anything' do
        expect { subject }.not_to change { instance.send(:scanner) }
      end
    end

    context 'when scanning is running' do
      before { described_class.run! }

      it 'should stop scanning' do
        expect { subject }.to change { instance.send(:scanner) }.to(nil)
      end
    end
  end

  describe '.running?' do
    after { described_class.stop! }

    subject(:result) { described_class.running? }

    describe 'result' do
      context 'when scanning is running' do
        before { described_class.run! }

        it { is_expected.to be_truthy }
      end

      context 'when scanning is not running' do
        it { is_expected.to be_falsey }
      end
    end
  end

  describe 'instance' do
    subject { described_class.instance }

    it { is_expected.to respond_to(:run!, :stop!, :running?) }

    it 'should have private method `scan`' do
      expect(subject.private_methods.include?(:scan)).to be_truthy
    end
  end

  describe '#run!' do
    after { instance.stop! }
    before { instance.stop! }

    subject { instance.run! }

    let(:instance) { described_class.instance }

    context 'when scanning is not running' do
      it 'should start scanning' do
        expect { subject }.to change { instance.send(:scanner) }.from(nil)
      end

      it 'should invoke `scan` method at least once' do
        expect(instance).to receive(:scan)
        subject
        sleep(0.5)
      end
    end

    context 'when scanning is running' do
      before { instance.run! }

      it 'shouldn\'t do anything' do
        expect { subject }.not_to change { instance.send(:scanner) }
      end
    end
  end

  describe '#stop!' do
    subject { instance.stop! }

    let(:instance) { described_class.instance }

    context 'when scanning is not running' do
      it 'shouldn\'t do anything' do
        expect { subject }.not_to change { instance.send(:scanner) }
      end
    end

    context 'when scanning is running' do
      before { instance.run! }

      it 'should stop scanning' do
        expect { subject }.to change { instance.send(:scanner) }.to(nil)
      end
    end
  end

  describe '#running?' do
    after { instance.stop! }

    subject(:result) { instance.running? }

    let(:instance) { described_class.instance }

    describe 'result' do
      context 'when scanning is running' do
        before { instance.run! }

        it { is_expected.to be_truthy }
      end

      context 'when scanning is not running' do
        it { is_expected.to be_falsey }
      end
    end
  end

  describe '#scan' do
    before { CaseCore::Logic::Loader.settings.dir = dir }

    subject { instance.send(:scan) }

    let(:instance) { described_class.instance }
    let(:dir) { "#{$root}/spec/fixtures/logic" }

    context 'when modification time of the directory is not changed' do
      before do
        FileUtils.touch(dir)
        mtime = File.mtime(dir)
        instance.instance_variable_set('@last_mtime', mtime)
      end

      it 'shouldn\'t load anything' do
        expect { subject }
          .not_to change { CaseCore::Logic::Loader.loaded_logics }
      end
    end

    context 'when modification time of the directory is changed' do
      before do
        instance.instance_variable_set('@last_mtime', nil)
        CaseCore::Logic::Loader.instance.send(:unload_module, 'test_case')
        CaseCore::Logic::Loader.instance.send(:unload_module, 'mixed_case')
      end

      it 'should load new modules' do
        expect { subject }
          .to change { CaseCore::Logic::Loader.loaded_logics.map(&:to_s).sort }
          .to(%w(MixedCASE TestCase))
      end
    end
  end
end
