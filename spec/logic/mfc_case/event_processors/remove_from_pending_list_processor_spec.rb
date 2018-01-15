# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса
# `MFCCase::EventProcessors::RemoveFromPendingListProcessor` обработчиков
# события `remove_from_pending_list` заявки на неавтоматизированную услугу
#

CaseCore::Logic::Loader.instance.send(:unload_module, 'mfc_case')
Object.send(:remove_const, :MFCCase) if Object.const_defined?(:MFCCase)

CaseCore::Logic::Loader.settings.dir = "#{$root}/logic"
CaseCore::Logic::Loader.logic('mfc_case')

helpers_path = "#{$root}/spec/helpers/mfc_case/event_processors"
load "#{helpers_path}/remove_from_pending_list_processor_spec_helper.rb"

RSpec.describe MFCCase::EventProcessors::RemoveFromPendingListProcessor do
  include MFCCase::EventProcessors::RemoveFromPendingListProcessorSpecHelper

  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:new) }
  end

  describe '.new' do
    subject(:result) { described_class.new(c4s3, params) }

    let(:params) { nil }

    describe 'result' do
      subject { result }

      let(:c4s3) { create_case(:pending, nil) }

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

    context 'when case status is absent' do
      let(:c4s3) { create(:case, type: :mfc_case) }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when case status is nil' do
      let(:c4s3) { create_case(nil, nil) }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when case status is not `pending`' do
      let(:c4s3) { create_case(:closed, nil) }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when `params` argument is not of `NilClass` nor of `Hash` type' do
      let(:params) { 'not of `NilClass` nor of `Hash` type' }
      let(:c4s3) { create_case('packaging', Time.now) }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end

  describe 'instance' do
    subject { described_class.new(c4s3, params) }

    let(:c4s3) { create_case(:pending, nil) }
    let(:params) { {} }

    it { is_expected.to respond_to(:process) }
  end

  describe '#process' do
    subject { instance.process }

    let(:instance) { described_class.new(c4s3, params) }
    let(:c4s3) { create_case(:pending, added_to_rejecting_at) }
    let(:added_to_rejecting_at) { nil }
    let(:params) { { operator_id: '123', register_id: register.id } }
    let(:register) { create(:register) }
    let!(:link) { put_cases_into_register(register, c4s3) }

    context 'when `added_to_rejecting_at` case attribute is present' do
      let(:added_to_rejecting_at) { Time.now }

      it 'should set case status to `rejecting`' do
        expect { subject }.to change { case_status(c4s3) }.to('rejecting')
      end
    end

    context 'when `added_to_rejecting_at` case attribute is absent or nil' do
      it 'should set case status to `packaging`' do
        expect { subject }.to change { case_status(c4s3) }.to('packaging')
      end
    end

    it 'should set `added_to_pending_at` case attribute to nil' do
      subject
      expect(case_added_to_pending_at(c4s3)).to be_nil
    end

    it 'should remove the case from the register' do
      expect { subject }
        .to change { case_registers.with_pk([c4s3.id, register.id]) }
        .to(nil)
    end

    context 'when the case is not in a register' do
      let!(:link) {}

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when the register contains only the case' do
      it 'should delete the register' do
        expect { subject }
          .to change { registers.with_pk(register.id) }
          .to(nil)
      end
    end

    context 'when the register contains other cases' do
      let(:another_case) { create(:case) }
      let!(:another_link) { put_cases_into_register(register, another_case) }

      it 'shouldn\'t delete the register' do
        expect { subject }.not_to change { registers.with_pk(register.id) }
      end
    end

    context 'when another register contains the case' do
      let(:register2) { create(:register) }
      let!(:link2) { put_cases_into_register(register2, c4s3) }

      it 'shouldn\'t remove the case from this older register' do
        expect { subject }
          .not_to change { case_registers.with_pk([c4s3.id, register2.id]) }
      end
    end
  end
end