# frozen_string_literal: true

# Файл тестирования модуля `CaseCore::Settings::Configurable`, который
# предоставляет методы для конфигурирования объектов

RSpec.describe CaseCore::Settings::Configurable do
  subject(:obj) { Object.new.extend(described_class) }

  it { is_expected.to respond_to(:settings, :configure) }

  it 'should have private methods #settings_names and #settings_class' do
    expect(subject.respond_to?(:settings_names, true)).to be_truthy
    expect(subject.respond_to?(:settings_class, true)).to be_truthy
  end

  describe '#settings' do
    before { obj.send(:settings_names, :option) }

    subject(:result) { obj.settings }

    let(:settings_class) { obj.send(:settings_class) }

    describe 'result' do
      subject { result }

      it 'should be an instance of settings class' do
        expect(subject).to be_a(settings_class)
      end
    end
  end

  describe '#configure' do
    before { obj.send(:settings_names, :option) }

    it 'should yield settings' do
      expect { |b| obj.configure(&b) }.to yield_with_args(obj.settings)
    end
  end

  describe '#settings_names' do
    subject(:result) { obj.send(:settings_names, *args) }

    let(:args) { %w[option setting] }

    describe 'result' do
      subject { result }

      it { is_expected.to be_an(Array) }
    end

    it 'should add names of settings' do
      expect { subject }.to change { obj.send(:settings_names).size }.by(2)
    end

    context 'when class of settings isn\'t set explicitly' do
      before { subject }

      it 'should set names of properties of settings object' do
        expect(obj.settings).to respond_to(*args)
      end
    end
  end

  describe '#settings_class' do
    before { obj.send(:settings_names, :option) }

    subject(:result) { obj.send(:settings_class) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(Class) }

      context 'when settings class is not set explicitly' do
        it { is_expected.to be < CaseCore::Settings::Mixin }
      end
    end
  end
end
