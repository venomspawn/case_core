# frozen_string_literal: true

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса `CaseCore::Logic::Loader::Scanner` объектов,
# сканирующих директорию с распакованными библиотеками бизнес-логики
#

RSpec.describe CaseCore::Logic::Loader::Scanner do
  before { CaseCore::Logic::Loader.settings.dir = dir }

  let(:dir) { "#{$root}/spec/fixtures/logic" }
  let!(:instance) { CaseCore::Logic::Loader.instance.send(:scanner) }

  describe 'instance' do
    subject { instance }

    it { is_expected.to respond_to(:libs, :reload_all) }
  end

  describe '#libs' do
    after { instance.send(:close_watcher) }

    subject(:result) { instance.libs }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(Hash) }

      describe 'keys' do
        subject { result.keys }

        let(:names) { %w[mixed_case syntax_error_case test_case wrong_case] }

        it 'should be names of libraries' do
          expect(subject).to match_array(names)
        end
      end

      describe 'values' do
        subject { result.values }

        let(:versions) { %w[0.0.1 0.0.1 0.0.2 0.0.1] }

        it 'should be versions of libraries' do
          expect(subject).to match_array(versions)
        end
      end
    end
  end

  describe '#reload_all' do
    after { instance.send(:close_watcher) }

    subject { instance.reload_all }

    it 'should reload modules' do
      expect { subject }
        .to change { CaseCore::Logic::Loader.logic('test_case').object_id }
    end

    it 'should reload libraries information' do
      expect { subject }.to change { instance.libs.object_id }
    end
  end

  describe 'directory scanning' do
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

    #   subject { FileUtils.rm_rf(dir) && sleep(0.01) }

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

    context 'when the directory is moved' do
      after { FileUtils.mv(temp_dir, dir) }

      subject { FileUtils.mv(dir, temp_dir) && sleep(0.01) }

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

      subject { FileUtils.touch(filepath) && sleep(0.01) }

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

      subject { FileUtils.mv(initial_filepath, filepath) && sleep(0.01) }

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

      subject { FileUtils.rm_rf(filepath) && sleep(0.01) }

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

      subject { FileUtils.mv(initial_filepath, filepath) && sleep(0.01) }

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

      let(:delay) { described_class::DELAY_DUE_CREATION + 0.01 }

      context 'when the subdirectory doesn\'t have proper name' do
        subject { FileUtils.mkdir(dirpath) && sleep(delay) }

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
          subject { FileUtils.mkdir(dirpath) && sleep(delay) }

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

          subject { FileUtils.cp_r(source_path, dirpath) || sleep(delay) }

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

    context 'when a subdirectory is moved to the directory' do
      before { FileUtils.cp_r(initial_path, source_path) }

      after { FileUtils.rm_rf([source_path, dirpath]) }

      subject { FileUtils.mv(source_path, dirpath) && sleep(0.1) }

      let(:name) { 'test_case' }
      let(:initial_path) { "#{dir}/#{name}-0.0.1" }
      let(:source_path) { "#{File.dirname(dir)}/#{name}-0.0.1" }

      context 'when the subdirectory doesn\'t have proper name' do
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

    context 'when a subdirectory is deleted in the directory' do
      subject { FileUtils.rm_rf(dirpath) && sleep(0.01) }

      context 'when the subdirectory doesn\'t have proper name' do
        before { FileUtils.mkdir(dirpath) }

        let(:dirpath) { "#{dir}/testabc" }

        it 'shouldn\'t unload any module' do
          expect { subject }
            .not_to change { CaseCore::Logic::Loader.loaded_logics }
        end

        it 'shouldn\'t change libraries information' do
          expect { subject }.not_to change { instance.libs }
        end
      end

      context 'when the subdirectory has proper name' do
        before { FileUtils.cp_r(dirpath, copy_path) }

        after { FileUtils.mv(copy_path, dirpath) }

        context 'when version is not of loaded module' do
          let(:dirpath) { "#{dir}/test_case-0.0.1" }
          let(:copy_path) { "#{File.dirname(dir)}/test_case-0.0.1" }

          it 'shouldn\'t unload any module' do
            expect { subject }
              .not_to change { CaseCore::Logic::Loader.loaded_logics }
          end

          it 'shouldn\'t change libraries information' do
            expect { subject }.not_to change { instance.libs }
          end
        end

        context 'when version is of loaded module' do
          let(:dirpath) { "#{dir}/#{name}-#{version}" }
          let(:copy_path) { "#{File.dirname(dir)}/#{name}-#{version}" }

          context 'when there is other version of the library' do
            let(:name) { 'test_case' }
            let(:version) { '0.0.2' }
            let(:new_version) { '0.0.1' }

            it 'should reload the module' do
              expect { subject }
                .to change { CaseCore::Logic::Loader.logic(name).object_id }
            end

            it 'should change the library information' do
              expect { subject }
                .to change { instance.libs[name] }
                .to(new_version)
            end
          end

          context 'when there is no other version of the library' do
            let(:name) { 'mixed_case' }
            let(:version) { '0.0.1' }

            it 'should unload the module' do
              expect { subject }
                .to change { CaseCore::Logic::Loader.logic(name) }
                .to(nil)
            end

            it 'should remove the library information' do
              expect { subject }
                .to change { instance.libs[name] }
                .to(nil)
            end
          end
        end
      end
    end

    context 'when a subdirectory is moved from the directory' do
      subject { FileUtils.mv(dirpath, target_path) && sleep(0.01) }

      let(:target_path) { "#{File.dirname(dir)}/#{File.basename(dirpath)}" }

      context 'when the subdirectory doesn\'t have proper name' do
        before { FileUtils.mkdir(dirpath) }

        after { FileUtils.rm_r(target_path) }

        let(:dirpath) { "#{dir}/testabc" }

        it 'shouldn\'t unload any module' do
          expect { subject }
            .not_to change { CaseCore::Logic::Loader.loaded_logics }
        end

        it 'shouldn\'t change libraries information' do
          expect { subject }.not_to change { instance.libs }
        end
      end

      context 'when the subdirectory has proper name' do
        after { FileUtils.mv(target_path, dirpath) }

        let(:dirpath) { "#{dir}/#{name}-#{version}" }

        context 'when version is not of loaded module' do
          let(:name) { 'test_case' }
          let(:version) { '0.0.1' }

          it 'shouldn\'t unload any module' do
            expect { subject }
              .not_to change { CaseCore::Logic::Loader.loaded_logics }
          end

          it 'shouldn\'t change libraries information' do
            expect { subject }.not_to change { instance.libs }
          end
        end

        context 'when version is of loaded module' do
          context 'when there is other version of the library' do
            let(:name) { 'test_case' }
            let(:version) { '0.0.2' }
            let(:new_version) { '0.0.1' }

            it 'should reload the module' do
              expect { subject }
                .to change { CaseCore::Logic::Loader.logic(name).object_id }
            end

            it 'should change the library information' do
              expect { subject }
                .to change { instance.libs[name] }
                .to(new_version)
            end
          end

          context 'when there is no other version of the library' do
            let(:name) { 'mixed_case' }
            let(:version) { '0.0.1' }

            it 'should unload the module' do
              expect { subject }
                .to change { CaseCore::Logic::Loader.logic(name) }
                .to(nil)
            end

            it 'should remove the library information' do
              expect { subject }
                .to change { instance.libs[name] }
                .to(nil)
            end
          end
        end
      end
    end
  end
end
