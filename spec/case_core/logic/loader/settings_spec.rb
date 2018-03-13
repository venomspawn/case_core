# frozen_string_literal: true

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса `CaseCore::Logic::Loader::Settings` настроек класса
# `CaseCore::Logic::Loader::Settings`
#

RSpec.describe CaseCore::Logic::Loader::Settings do
  subject(:settings) { CaseCore::Logic::Loader.settings }

  it { is_expected.to be_a_kind_of(CaseCore::Settings::Mixin) }
  it { is_expected.to respond_to(:dir, :dir=) }

  describe '#dir=' do
    subject { settings.dir = dir }

    let(:dir) { "#{$root}/spec/fixtures/logic" }
    let(:loader) { CaseCore::Logic::Loader.instance }
    let(:scanner) { loader.send(:scanner) }

    it 'should reload modules' do
      expect { subject }.to change { loader.logic('test_case').object_id }
    end

    it 'should reload libraries information' do
      expect { subject }.to change { scanner.libs.object_id }
    end

    context 'when value is not a path to a directory with libraries' do
      let(:dir) { 'not a path to a directory' }

      it 'should unload all loaded modules' do
        subject
        expect(loader.loaded_logics).to be_empty
      end

      it 'should unload all libraries information' do
        subject
        expect(scanner.libs).to be_empty
      end
    end

    context 'when value is a path to a directory with libraries' do
      it 'should load all loaded modules' do
        subject
        expect(loader.loaded_logics).not_to be_empty
      end

      it 'should load all libraries information' do
        subject
        expect(scanner.libs).not_to be_empty
      end
    end
  end
end
