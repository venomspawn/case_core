# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса `CaseCore::Logic::Loader` загрузчика бизнес-логики
#

RSpec.describe CaseCore::Logic::Loader do
  subject 'the class' do
    subject { described_class }

    it { is_expected.not_to respond_to(:new) }
    it { is_expected.to respond_to(:instance, :logic, :loaded_logics) }
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
    before do
      described_class.settings.dir = dir
      described_class.settings.dir_check_period = 10
    end

    subject(:result) { described_class.logic(name) }

    let(:name) { 'test_case' }
    let(:dir) { "#{$root}/spec/fixtures/logic" }
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
            described_class.instance.send(:unload_module, name)
            FileUtils.mv("#{dir}/#{name}-#{version}", "#{dir}/#{name}bak")
            described_class.instance.send(:scanner).libs.clear
            described_class.instance.send(:scanner).send(:scan)

            logic = described_class.instance.logic(name)

            FileUtils.mv("#{dir}/#{name}bak", "#{dir}/#{name}-#{version}")
            FileUtils.touch(dir, mtime: Time.now + 1)
            described_class.instance.send(:scanner).libs[name] = version

            expect(subject).not_to be == logic
          end

          it 'should call `on_unload` method of the old module' do
            described_class.instance.send(:unload_module, name)
            FileUtils.mv("#{dir}/#{name}-#{version}", "#{dir}/#{name}bak")
            described_class.instance.send(:scanner).libs.clear
            described_class.instance.send(:scanner).send(:scan)

            logic = described_class.instance.logic(name)

            allow(logic).to receive(:on_load)
            allow(logic).to receive(:on_unload)

            FileUtils.mv("#{dir}/#{name}bak", "#{dir}/#{name}-#{version}")
            FileUtils.touch(dir, mtime: Time.now + 1)
            described_class.instance.send(:scanner).libs[name] = version

            expect(logic).to receive(:on_unload)
            subject
          end

          it 'should call `on_load` method of the new module' do
            described_class.instance.send(:unload_module, name)
            FileUtils.mv("#{dir}/#{name}-#{version}", "#{dir}/#{name}bak")
            described_class.instance.send(:scanner).libs.clear
            described_class.instance.send(:scanner).send(:scan)

            described_class.instance.logic(name)

            FileUtils.mv("#{dir}/#{name}bak", "#{dir}/#{name}-#{version}")
            FileUtils.touch(dir, mtime: Time.now + 1)
            described_class.instance.send(:scanner).libs[name] = version

            expect(described_class.instance)
              .to receive(:call_logic_func)
              .with(instance_of(described_class::ModuleInfo), :on_unload)
            expect(described_class.instance)
              .to receive(:call_logic_func)
              .with(instance_of(described_class::ModuleInfo), :on_load)
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
    before do
      described_class.configure do |settings|
        settings.set :dir,              dir
        settings.set :dir_check_period, 0
      end

      described_class.logic(name)
    end

    subject(:result) { described_class.loaded_logics }

    let(:name) { 'test_case' }
    let(:dir) { "#{$root}/spec/fixtures/logic" }

    describe 'result' do
      subject { result }

      it { is_expected.to be_an(Array) }

      describe 'elements' do
        it { is_expected.to all(be_a(Module)) }
      end
    end
  end

  describe 'instance' do
    subject { described_class.instance }

    it { is_expected.to respond_to(:logic, :loaded_logics) }
  end

  describe '#logic' do
    before do
      described_class.configure do |settings|
        settings.set :dir,              dir
        settings.set :dir_check_period, 10
      end
    end

    subject(:result) { instance.logic(name) }

    let(:instance) { described_class.instance }
    let(:name) { 'test_case' }
    let(:dir) { "#{$root}/spec/fixtures/logic" }
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
            described_class.instance.send(:unload_module, name)
            FileUtils.mv("#{dir}/#{name}-#{version}", "#{dir}/#{name}bak")
            described_class.instance.send(:scanner).libs.clear
            described_class.instance.send(:scanner).send(:scan)

            logic = described_class.instance.logic(name)

            FileUtils.mv("#{dir}/#{name}bak", "#{dir}/#{name}-#{version}")
            FileUtils.touch(dir, mtime: Time.now + 1)
            described_class.instance.send(:scanner).libs[name] = version

            expect(subject).not_to be == logic
          end

          it 'should call `on_unload` method of the old module' do
            described_class.instance.send(:unload_module, name)
            FileUtils.mv("#{dir}/#{name}-#{version}", "#{dir}/#{name}bak")
            described_class.instance.send(:scanner).libs.clear
            described_class.instance.send(:scanner).send(:scan)

            logic = described_class.instance.logic(name)

            allow(logic).to receive(:on_load)
            allow(logic).to receive(:on_unload)

            FileUtils.mv("#{dir}/#{name}bak", "#{dir}/#{name}-#{version}")
            FileUtils.touch(dir, mtime: Time.now + 1)
            described_class.instance.send(:scanner).libs[name] = version

            expect(logic).to receive(:on_unload)
            subject
          end

          it 'should call `on_load` method of the new module' do
            described_class.instance.send(:unload_module, name)
            FileUtils.mv("#{dir}/#{name}-#{version}", "#{dir}/#{name}bak")
            described_class.instance.send(:scanner).libs.clear
            described_class.instance.send(:scanner).send(:scan)

            described_class.instance.logic(name)

            FileUtils.mv("#{dir}/#{name}bak", "#{dir}/#{name}-#{version}")
            FileUtils.touch(dir, mtime: Time.now + 1)
            described_class.instance.send(:scanner).libs[name] = version

            expect(described_class.instance)
              .to receive(:call_logic_func)
              .with(instance_of(described_class::ModuleInfo), :on_unload)
            expect(described_class.instance)
              .to receive(:call_logic_func)
              .with(instance_of(described_class::ModuleInfo), :on_load)
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
    before do
      described_class.configure do |settings|
        settings.set :dir,              dir
        settings.set :dir_check_period, 0
      end

      instance.logic(name)
    end

    subject(:result) { instance.loaded_logics }

    let(:instance) { described_class.instance }
    let(:name) { 'test_case' }
    let(:dir) { "#{$root}/spec/fixtures/logic" }

    describe 'result' do
      subject { result }

      it { is_expected.to be_an(Array) }

      describe 'elements' do
        it { is_expected.to all(be_a(Module)) }
      end
    end
  end
end
