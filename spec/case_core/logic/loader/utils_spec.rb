# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса `CaseCore::Logic::Loader::Utils` вспомогательных
# объектов, осуществляющих проверки на наличие обновлений модулей бизнес-логики
#

RSpec.describe CaseCore::Logic::Loader::Utils do
  let(:instance) { described_class.new(dir, name, info) }
  let(:dir) { "#{$root}/spec/fixtures/logic" }
  let(:name) { 'test_case' }
  let(:info) { CaseCore::Logic::Loader::ModuleInfo.new(version, Object) }
  let(:allow_to_reload) { true }
  let(:version) { '0.0.2' }

  describe 'instance' do
    subject { instance }

    it { is_expected.to respond_to(:reload?, :filename, :last_lib_version) }
  end

  describe '#reload?' do
    subject(:result) { instance.reload? }

    describe 'result' do
      subject { result }

      context 'when nothing has changed' do
        it { is_expected.to be_falsey }
      end

      context 'when only content of the directory has changed' do
        before { FileUtils.touch(dir, mtime: Time.now + 1) }

        it { is_expected.to be_falsey }
      end

      context 'when only version has changed' do
        before { FileUtils.touch(dir, mtime: Time.now - 1) }

        let(:version) { '0.0.1' }

        it { is_expected.to be_falsey }
      end

      context 'when content of the directory and version have changed' do
        before { FileUtils.touch(dir, mtime: Time.now + 1) }

        let(:version) { '0.0.1' }

        it { is_expected.to be_truthy }
      end
    end
  end

  describe '#filename' do
    subject(:result) { instance.filename }

    describe 'result' do
      subject { result }

      let(:path) { "#{dir}/#{name}-#{version}/lib/#{name}.rb" }

      it 'should be a path to the module source file' do
        expect(subject).to be == path
      end
    end
  end

  describe '#last_lib_version' do
    subject(:result) { instance.last_lib_version }

    describe 'result' do
      subject { result }

      context 'when there is a library for the module' do
        it 'should return last version of the library' do
          expect(subject).to be == version
        end
      end

      context 'when a library for the module is absent' do
        let(:name) { 'no_library' }

        it { is_expected.to be_nil }
      end
    end
  end
end
