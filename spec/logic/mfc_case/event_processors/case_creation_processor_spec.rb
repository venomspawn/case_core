# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса `MFCCase::EventProcessors::CaseCreationProcessor`
# обработчиков события создания заявки на неавтоматизированную услугу
#

CaseCore::Logic::Loader.instance.send(:unload_module, 'mfc_case')
Object.send(:remove_const, :MFCCase) if Object.const_defined?(:MFCCase)

CaseCore::Logic::Loader.settings.dir = "#{$root}/logic"
CaseCore::Logic::Loader.logic('mfc_case')

helpers_path = "#{$root}/spec/helpers/mfc_case/event_processors"
load "#{helpers_path}/case_creation_processor_spec_helper.rb"

RSpec.describe MFCCase::EventProcessors::CaseCreationProcessor do
  include MFCCase::EventProcessors::CaseCreationProcessorSpecHelper

  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:new) }
  end

  describe '.new' do
    subject(:result) { described_class.new(c4s3) }

    describe 'result' do
      subject { result }

      let(:c4s3) { create(:case, type: 'mfc_case') }

      it { is_expected.to be_an_instance_of(described_class) }
    end

    context 'when `case` argument is not of `CaseCore::Models::Case` type' do
      let(:c4s3) { 'not of `CaseCore::Models::Case` type' }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when case type is wrong' do
      let(:c4s3) { create(:case, type: 'wrong') }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when case status is present' do
      let(:c4s3) { create(:case, type: 'mfc_case') }
      let!(:case_attribute) { create(:case_attribute, *traits) }
      let(:traits) { [case: c4s3, name: 'status', value: 'status'] }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end
  end

  describe 'instance' do
    subject { described_class.new(c4s3) }

    let(:c4s3) { create(:case, type: 'mfc_case') }

    it { is_expected.to respond_to(:process) }
  end

  describe '#process' do
    subject { instance.process }

    let(:instance) { described_class.new(c4s3) }
    let(:c4s3) { create(:case, type: 'mfc_case') }

    it 'should set case status to `packaging`' do
      expect { subject }.to change { case_status(c4s3) }.to('packaging')
    end
  end
end
