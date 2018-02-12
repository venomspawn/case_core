# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса `MSPCase::EventProcessors::ChangeStatusToProcessor`
# обработчиков события `change_status_to` заявки на МСП-услугу
#

CaseCore::Logic::Loader.instance.send(:unload_module, 'msp_case')
Object.send(:remove_const, :MSPCase) if Object.const_defined?(:MSPCase)

CaseCore::Logic::Loader.settings.dir = "#{$root}/logic"
CaseCore::Logic::Loader.logic('msp_case')

helpers_path = "#{$root}/spec/helpers/msp_case/event_processors"
load "#{helpers_path}/change_status_to_processor_spec_helper.rb"

RSpec.describe MSPCase::EventProcessors::ChangeStatusToProcessor do
  include MSPCase::EventProcessors::ChangeStatusToProcessorSpecHelper

  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:new) }
  end

  describe '.new' do
    subject(:result) { described_class.new(c4s3, status, params) }

    let(:params) { {} }
    let(:status) { 'closed' }

    describe 'result' do
      subject { result }

      let(:c4s3) { create_case('issuance') }

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

    context 'when case status isn\'t `issuance`' do
      let(:c4s3) { create_case('not `issuance`') }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when `params` argument isn\'t of `NilClass` nor of `Hash` type' do
      let(:c4s3) { create_case('issuance') }
      let(:params) { 'not of `NilClass` nor of `Hash` type' }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when `status` argument isn\'t `closed`' do
      let(:c4s3) { create_case('issuance') }
      let(:status) { 'not `closed`' }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end

  describe 'instance' do
    subject { described_class.new(c4s3, status, params) }

    let(:c4s3) { create_case('issuance') }
    let(:params) { {} }
    let(:status) { 'closed' }

    it { is_expected.to respond_to(:process) }
  end

  describe '#process' do
    subject { instance.process }

    let(:instance) { described_class.new(c4s3, status, params) }
    let(:c4s3) { create_case('issuance') }
    let(:params) { {} }
    let(:status) { 'closed' }

    it 'should set case status to `closed`' do
      expect { subject }.to change { case_status(c4s3) }.to('closed')
    end

    it 'should set `closed_at` case attribute to now time' do
      subject
      expect(case_closed_at(c4s3)).to be_within(1).of(Time.now)
    end
  end
end
