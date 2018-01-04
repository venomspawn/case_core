# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса `CaseCore::Logic::Loader::Scanner` объектов,
# сканирующих директорию с распакованными библиотеками бизнес-логики
#

RSpec.describe CaseCore::Logic::Loader::Scanner do
  let(:loader_instance) { CaseCore::Logic::Loader.instance }

  describe 'instance' do
    subject { loader_instance.send(:scanner) }

    it { is_expected.to respond_to(:libs) }

    it 'should have private method `scan`' do
      expect(subject.private_methods.include?(:scan)).to be_truthy
    end
  end

  describe '#libs' do
    before { CaseCore::Logic::Loader.settings.dir = dir }

    subject(:result) { instance.libs }

    let(:instance) { loader_instance.send(:scanner) }
    let(:dir) { "#{$root}/spec/fixtures/logic" }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(Hash) }

      describe 'keys' do
        before { instance.send(:scan) }

        subject { result.keys }

        let(:names) { %w(mixed_case syntax_error_case test_case wrong_case) }

        it 'should be names of libraries' do
          expect(subject).to match_array(names)
        end
      end

      describe 'values' do
        before { instance.send(:scan) }

        subject { result.values }

        let(:versions) { %w(0.0.1 0.0.1 0.0.2 0.0.1) }

        it 'should be versions of libraries' do
          expect(subject).to match_array(versions)
        end
      end
    end
  end

  describe '#scan' do
    before do
      CaseCore::Logic::Loader.settings.dir = dir
      CaseCore::Logic::Loader.settings.dir_check_period = 1
    end

    subject { instance.send(:scan) }

    let(:instance) { loader_instance.send(:scanner) }
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

        loader_instance.send(:unload_module, 'test_case')
        loader_instance.send(:unload_module, 'mixed_case')
        loader_instance.instance_variable_set('@modules_info', {})
      end

      it 'should load new modules' do
        expect { subject }
          .to change { CaseCore::Logic::Loader.loaded_logics.map(&:to_s).sort }
          .to(%w(MixedCASE TestCase))
      end
    end
  end
end
