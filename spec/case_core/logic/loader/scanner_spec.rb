# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса `CaseCore::Logic::Loader::Scanner` объектов,
# сканирующих директорию с распакованными библиотеками бизнес-логики
#

RSpec.describe CaseCore::Logic::Loader::Scanner do
  before { CaseCore::Logic::Loader.settings.dir = dir }

  let(:dir) { "#{$root}/spec/fixtures/logic" }

  describe 'instance' do
    subject { described_class.new }

    it { is_expected.to respond_to(:libs, :reload_all) }
  end

  describe '#libs' do
    subject(:result) { instance.libs }

    let(:instance) { described_class.new }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(Hash) }

      describe 'keys' do
        subject { result.keys }

        let(:names) { %w(mixed_case syntax_error_case test_case wrong_case) }

        it 'should be names of libraries' do
          expect(subject).to match_array(names)
        end
      end

      describe 'values' do
        subject { result.values }

        let(:versions) { %w(0.0.1 0.0.1 0.0.2 0.0.1) }

        it 'should be versions of libraries' do
          expect(subject).to match_array(versions)
        end
      end
    end
  end

  describe '#reload_all' do
    subject { instance.reload_all }

    let(:instance) { described_class.new }

    it 'should reload modules' do
      expect { subject }
        .to change { CaseCore::Logic::Loader.logic('test_case').object_id }
    end

    it 'should reload libraries information' do
      expect { subject }.to change { instance.libs.object_id }
    end
  end

  describe 'directory scanning' do
    let!(:instance) { described_class.new }

    # Закомментировано из-за следующей проблемы. Тесты выполняются в директории
    # `/vagrant`, которая примонтирована с типом файловой системы `vboxsf`.
    # Судя по всему, в этой файловой системе событие `IN_DELETE_SELF` не
    # создаётся при удалении директории, хотя если запускать тесты в домашней
    # директории (`/home/vagrant`), то событие корректно создаётся и
    # обрабатывается.
    #
    # context 'when the directory is deleted' do
    #   before { FileUtils.cp_r(dir, temp_dir) }

    #   after { FileUtils.mv(temp_dir, dir) }

    #   subject { FileUtils.rm_rf(dir); sleep(0.01) }

    #   let(:temp_dir) { "#{dir}.tmp" }

    #   it 'should unload all modules' do
    #     expect { subject }
    #       .to change { CaseCore::Logic::Loader.loaded_logics }
    #       .to([])
    #   end

    #   it 'should remove libraries information' do
    #     expect { subject }.to change { instance.libs }.to({})
    #   end
    # end

    context 'when then directory is moved' do
      after { FileUtils.mv(temp_dir, dir) }

      subject { FileUtils.mv(dir, temp_dir); sleep(0.01) }

      let(:temp_dir) { "#{dir}.tmp" }

      it 'should unload all modules' do
        expect { subject }
          .to change { CaseCore::Logic::Loader.loaded_logics }
          .to([])
      end

      it 'should remove libraries information' do
        expect { subject }.to change { instance.libs }.to({})
      end
    end

    context 'when a file is created in the directory' do
      after { FileUtils.rm_rf(filepath) }

      subject { FileUtils.touch(filepath); sleep(0.01) }

      let(:filepath) { "#{dir}/test-6.6.6" }

      it 'shouldn\'t load any module' do
        expect { subject }
          .not_to change { CaseCore::Logic::Loader.loaded_logics }
      end

      it 'shouldn\'t change libraries information' do
        expect { subject }.not_to change { instance.libs }
      end
    end

    context 'when a file is moved to the directory' do
      before { FileUtils.touch(initial_filepath) }

      after { FileUtils.rm_rf(filepath) }

      subject { FileUtils.mv(initial_filepath, filepath); sleep(0.01) }

      let(:initial_filepath) { "#{File.basename(dir)}/test-6.6.6" }
      let(:filepath) { "#{dir}/test-6.6.6" }

      it 'shouldn\'t load any module' do
        expect { subject }
          .not_to change { CaseCore::Logic::Loader.loaded_logics }
      end

      it 'shouldn\'t change libraries information' do
        expect { subject }.not_to change { instance.libs }
      end
    end

    context 'when a file is deleted in the directory' do
      before { FileUtils.touch(filepath) }

      subject { FileUtils.rm_rf(filepath); sleep(0.01) }

      let(:filepath) { "#{dir}/test-6.6.6" }

      it 'shouldn\'t load any module' do
        expect { subject }
          .not_to change { CaseCore::Logic::Loader.loaded_logics }
      end

      it 'shouldn\'t change libraries information' do
        expect { subject }.not_to change { instance.libs }
      end
    end

    context 'when a file is moved from the directory' do
      before { FileUtils.touch(initial_filepath) }

      after { FileUtils.rm_rf(filepath) }

      subject { FileUtils.mv(initial_filepath, filepath); sleep(0.01) }

      let(:filepath) { "#{File.basename(dir)}/test-6.6.6" }
      let(:initial_filepath) { "#{dir}/test-6.6.6" }

      it 'shouldn\'t load any module' do
        expect { subject }
          .not_to change { CaseCore::Logic::Loader.loaded_logics }
      end

      it 'shouldn\'t change libraries information' do
        expect { subject }.not_to change { instance.libs }
      end
    end

    context 'when a subdirectory is created in the directory' do
      after { FileUtils.rm_rf(dirpath) }

      context 'when the subdirectory doesn\'t have proper name' do
        subject { FileUtils.mkdir(dirpath); sleep(0.01) }

        let(:dirpath) { "#{dir}/testabc" }

        it 'shouldn\'t load any module' do
          expect { subject }
            .not_to change { CaseCore::Logic::Loader.loaded_logics }
        end

        it 'shouldn\'t change libraries information' do
          expect { subject }.not_to change { instance.libs }
        end
      end

      context 'when the subdirectory has proper name' do
        context 'when version is less than of loaded module' do
          subject { FileUtils.mkdir(dirpath); sleep(0.01) }

          let(:dirpath) { "#{dir}/test_case-0.0.0" }

          it 'shouldn\'t load any module' do
            expect { subject }
              .not_to change { CaseCore::Logic::Loader.loaded_logics }
          end

          it 'shouldn\'t change libraries information' do
            expect { subject }.not_to change { instance.libs }
          end
        end

        context 'when version is more than of loaded module' do
          before { FileUtils.cp_r(initial_path, source_path) }

          after { FileUtils.rm_rf(source_path) }

          subject { FileUtils.cp_r(source_path, dirpath); sleep(0.01) }

          let(:name) { 'test_case' }
          let(:source_path) { "#{File.dirname(dir)}/#{name}-0.0.1" }
          let(:initial_path) { "#{dir}/#{name}-0.0.1" }
          let(:dirpath) { "#{dir}/#{name}-#{version}" }
          let(:version) { '0.0.3' }

          it 'should reload the module' do
            expect { subject }
              .to change { CaseCore::Logic::Loader.logic(name).object_id }
          end

          it 'should change library information' do
            expect { subject }.to change { instance.libs[name] }.to(version)
          end
        end
      end
    end
  end
end
