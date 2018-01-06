# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса `CaseCore::Logic::Loader` загрузчика бизнес-логики
#

RSpec.describe CaseCore::Logic::Loader do
  subject 'the class' do
    subject { described_class }

    it { is_expected.not_to respond_to(:new) }

    functions = %i(instance logic loaded_logics reload_all unload)
    it { is_expected.to respond_to(*functions) }
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

  describe '.logic' do
    before { described_class.settings.dir = dir }

    subject(:result) { described_class.logic(name) }

    let(:dir) { "#{$root}/spec/fixtures/logic" }
    let(:name) { 'test_case' }
    let(:version) { '0.0.2' }

    describe 'result' do
      subject { result }

      context 'when library is found' do
        it { is_expected.to be_a(Module) }

        it 'should be in `Object` namespace' do
          expect(result).to be == Object::TestCase
        end

        it 'should have the latest version' do
          expect(result::VERSION).to be == version
        end

        context 'when module is of older version' do
          it 'should reload the module' do
            FileUtils.mv("#{dir}/#{name}-#{version}", "#{dir}/#{name}bak")
            described_class.reload_all
            logic = described_class.instance.logic(name)
            FileUtils.mv("#{dir}/#{name}bak", "#{dir}/#{name}-#{version}")

            # Задержка, необходимая для обработки события о том, что появилась
            # новая версия библиотеки (обработка выполняется в отдельном
            # потоке)
            sleep(0.01)

            expect(subject).not_to be == logic
          end

          it 'should call `on_unload` method of the old module' do
            FileUtils.mv("#{dir}/#{name}-#{version}", "#{dir}/#{name}bak")
            described_class.reload_all

            logic = described_class.instance.logic(name)
            allow(logic).to receive(:on_load)
            allow(logic).to receive(:on_unload)
            expect(logic).to receive(:on_unload)

            FileUtils.mv("#{dir}/#{name}bak", "#{dir}/#{name}-#{version}")

            # Задержка, необходимая для обработки события о том, что появилась
            # новая версия библиотеки (обработка выполняется в отдельном
            # потоке)
            sleep(0.01)

            subject
          end

          it 'should call `on_load` method of the new module' do
            FileUtils.mv("#{dir}/#{name}-#{version}", "#{dir}/#{name}bak")
            described_class.reload_all
            FileUtils.mv("#{dir}/#{name}bak", "#{dir}/#{name}-#{version}")

            expect(described_class.instance)
              .to receive(:call_logic_func)
              .with(instance_of(described_class::ModuleInfo), :on_unload)
            expect(described_class.instance)
              .to receive(:call_logic_func)
              .with(instance_of(described_class::ModuleInfo), :on_load)

            # Задержка, необходимая для обработки события о том, что появилась
            # новая версия библиотеки (обработка выполняется в отдельном
            # потоке)
            sleep(0.01)

            subject
          end
        end

        context 'when character cases are mixed in the module name' do
          let(:name) { 'mixed_case' }

          it 'should still be loaded' do
            expect(subject).to be == Object::MixedCASE
          end
        end

        context 'when loading raises an error' do
          let(:name) { 'syntax_error_case' }

          it { is_expected.to be_nil }
        end

        context 'when module can\'t be found by the name' do
          let(:name) { 'wrong_case' }

          it { is_expected.to be_nil }
        end
      end

      context 'when library isn\'t found' do
        let(:name) { 'won\'t be found' }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '.loaded_logics' do
    before { described_class.settings.dir = dir }

    subject(:result) { described_class.loaded_logics }

    let(:dir) { "#{$root}/spec/fixtures/logic" }

    describe 'result' do
      subject { result }

      it { is_expected.to be_an(Array) }

      describe 'elements' do
        it { is_expected.to all(be_a(Module)) }
      end
    end
  end

  describe '.reload_all' do
    before { described_class.settings.dir = dir }

    subject { described_class.reload_all }

    let(:instance) { described_class.instance }
    let(:scanner) { instance.send(:scanner) }
    let(:dir) { "#{$root}/spec/fixtures/logic" }

    it 'should reload modules' do
      expect { subject }
        .to change { described_class.logic('test_case').object_id }
    end

    it 'should reload libraries information' do
      expect { subject }.to change { scanner.libs.object_id }
    end
  end

  describe '#unload' do
    before { described_class.settings.dir = dir }

    subject(:result) { described_class.unload(logic) }

    let(:dir) { "#{$root}/spec/fixtures/logic" }

    describe 'result' do
      subject { result }

      context 'when module is found' do
        let(:logic) { 'test_case' }

        it { is_expected.to be_a(Module) }
      end

      context 'when module isn\'t found' do
        let(:logic) { 'won\'t be found' }

        it { is_expected.to be_nil }
      end
    end

    context 'when module is found' do
      let(:logic) { 'test_case' }

      it 'should unload module from Object namespace' do
        expect { subject }
          .to change { Object.const_defined?('TestCase') }
          .from(true)
          .to(false)
      end
    end

    context 'when module isn\'t found' do
      let(:logic) { 'won\'t be found' }

      it 'shouldn\'t unload modules from Object namespace' do
        expect { subject }.not_to change { Object.constants }
      end
    end
  end

  describe 'instance' do
    subject { described_class.instance }

    methods = %i(logic loaded_logics reload_all unload)
    it { is_expected.to respond_to(*methods) }
  end

  describe '#logic' do
    before { described_class.settings.dir = dir }

    subject(:result) { instance.logic(name) }

    let(:instance) { described_class.instance }
    let(:dir) { "#{$root}/spec/fixtures/logic" }
    let(:name) { 'test_case' }
    let(:version) { '0.0.2' }

    describe 'result' do
      subject { result }

      context 'when library is found' do
        it { is_expected.to be_a(Module) }

        it 'should be in `Object` namespace' do
          expect(result).to be == Object::TestCase
        end

        it 'should have the latest version' do
          expect(result::VERSION).to be == version
        end

        context 'when module is of older version' do
          it 'should reload the module' do
            FileUtils.mv("#{dir}/#{name}-#{version}", "#{dir}/#{name}bak")
            described_class.reload_all
            logic = described_class.instance.logic(name)
            FileUtils.mv("#{dir}/#{name}bak", "#{dir}/#{name}-#{version}")

            # Задержка, необходимая для обработки события о том, что появилась
            # новая версия библиотеки (обработка выполняется в отдельном
            # потоке)
            sleep(0.01)

            expect(subject).not_to be == logic
          end

          it 'should call `on_unload` method of the old module' do
            FileUtils.mv("#{dir}/#{name}-#{version}", "#{dir}/#{name}bak")
            described_class.reload_all

            logic = described_class.instance.logic(name)
            allow(logic).to receive(:on_load)
            allow(logic).to receive(:on_unload)
            expect(logic).to receive(:on_unload)

            FileUtils.mv("#{dir}/#{name}bak", "#{dir}/#{name}-#{version}")

            # Задержка, необходимая для обработки события о том, что появилась
            # новая версия библиотеки (обработка выполняется в отдельном
            # потоке)
            sleep(0.01)

            subject
          end

          it 'should call `on_load` method of the new module' do
            FileUtils.mv("#{dir}/#{name}-#{version}", "#{dir}/#{name}bak")
            described_class.reload_all
            FileUtils.mv("#{dir}/#{name}bak", "#{dir}/#{name}-#{version}")

            expect(instance)
              .to receive(:call_logic_func)
              .with(instance_of(described_class::ModuleInfo), :on_unload)
            expect(instance)
              .to receive(:call_logic_func)
              .with(instance_of(described_class::ModuleInfo), :on_load)

            # Задержка, необходимая для обработки события о том, что появилась
            # новая версия библиотеки (обработка выполняется в отдельном
            # потоке)
            sleep(0.01)

            subject
          end
        end

        context 'when character cases are mixed in the module name' do
          let(:name) { 'mixed_case' }

          it 'should still be loaded' do
            expect(subject).to be == Object::MixedCASE
          end
        end

        context 'when loading raises an error' do
          let(:name) { 'syntax_error_case' }

          it { is_expected.to be_nil }
        end

        context 'when module can\'t be found by the name' do
          let(:name) { 'wrong_case' }

          it { is_expected.to be_nil }
        end
      end

      context 'when library isn\'t found' do
        let(:name) { 'won\'t be found' }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#loaded_logics' do
    before { described_class.settings.dir = dir }

    subject(:result) { instance.loaded_logics }

    let(:instance) { described_class.instance }
    let(:dir) { "#{$root}/spec/fixtures/logic" }

    describe 'result' do
      subject { result }

      it { is_expected.to be_an(Array) }

      describe 'elements' do
        it { is_expected.to all(be_a(Module)) }
      end
    end
  end

  describe '#reload_all' do
    before { described_class.settings.dir = dir }

    subject { instance.reload_all }

    let(:instance) { described_class.instance }
    let(:scanner) { instance.send(:scanner) }
    let(:dir) { "#{$root}/spec/fixtures/logic" }

    it 'should reload modules' do
      expect { subject }.to change { instance.logic('test_case').object_id }
    end

    it 'should reload libraries information' do
      expect { subject }.to change { scanner.libs.object_id }
    end
  end

  describe '#unload' do
    before { described_class.settings.dir = dir }

    subject(:result) { instance.unload(logic) }

    let(:instance) { described_class.instance }
    let(:dir) { "#{$root}/spec/fixtures/logic" }

    describe 'result' do
      subject { result }

      context 'when module is found' do
        let(:logic) { 'test_case' }

        it { is_expected.to be_a(Module) }
      end

      context 'when module isn\'t found' do
        let(:logic) { 'won\'t be found' }

        it { is_expected.to be_nil }
      end
    end

    context 'when module is found' do
      let(:logic) { 'test_case' }

      it 'should unload module from Object namespace' do
        expect { subject }
          .to change { Object.const_defined?('TestCase') }
          .from(true)
          .to(false)
      end
    end

    context 'when module isn\'t found' do
      let(:logic) { 'won\'t be found' }

      it 'shouldn\'t unload modules from Object namespace' do
        expect { subject }.not_to change { Object.constants }
      end
    end
  end
end
