# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования модуля `CaseCore::Actions::Cases::Mixins::Logic`,
# предоставляющего поддержку извлечения модуля бизнес-логики по типу заявки
#

RSpec.describe CaseCore::Actions::Cases::Mixins::Logic do
  let(:instance) { Object.new.extend described_class }

  describe 'instance' do
    subject { instance }

    it 'should have private method `logic`' do
      expect(subject.private_methods(true).include?(:logic)).to be_truthy
    end
  end

  describe '#logic' do
    subject(:result) { instance.send(:logic, c4s3) }

    context 'when argument is not of `CaseCore::Models::Case` model' do
      let(:c4s3) { 'not of `CaseCore::Models::Case` model' }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when module can\'t be found by case type' do
      let(:c4s3) { create(:case, type: type) }
      let(:type) { 'a type' }

      it { is_expected.to be_nil }
    end

    context 'when module can be found by case type' do
      before { CaseCore::Logic::Loader.settings.dir = dir }

      let(:c4s3) { create(:case, type: type) }
      let(:type) { 'test_case' }
      let(:dir) { "#{$root}/spec/fixtures/logic" }

      it { is_expected.to be_a(Module) }
    end
  end
end
