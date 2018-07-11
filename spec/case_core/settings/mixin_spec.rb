# frozen_string_literal: true

# Тестирование модуля `CaseCore::Settings::Mixin`, который предназначен
# для включения в классы настроек

RSpec.describe CaseCore::Settings::Mixin do
  subject(:settings) { Struct.new(:option).new.extend(described_class) }

  it { is_expected.to respond_to(:set, :enable, :disable) }

  describe '#set' do
    subject { settings.set :option, value }

    let(:value) { create(:string) }

    it 'should set value of the option' do
      expect { subject }.to change { settings.option }.to(value)
    end
  end

  describe '#enable' do
    before { settings.option = false }

    subject { settings.enable :option }

    it 'should set value of the option to `true`' do
      expect { subject }.to change { settings.option }.to(true)
    end
  end

  describe '#disable' do
    before { settings.option = true }

    subject { settings.disable :option }

    it 'should set value of the option to `false`' do
      expect { subject }.to change { settings.option }.to(false)
    end
  end
end
