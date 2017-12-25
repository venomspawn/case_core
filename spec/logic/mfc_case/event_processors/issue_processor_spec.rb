# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса `MFCCase::EventProcessors::IssueProcessor`
# обработчиков события `issue` заявки на неавтоматизированную услугу
#

CaseCore::Logic::Loader.instance.send(:unload_module, 'mfc_case')
Object.send(:remove_const, :MFCCase) if Object.const_defined?(:MFCCase)

CaseCore::Logic::Loader.settings.dir = "#{$root}/logic"
CaseCore::Logic::Loader.logic('mfc_case')

helpers_path = "#{$root}/spec/helpers/mfc_case/event_processors"
load "#{helpers_path}/issue_processor_spec_helper.rb"

RSpec.describe MFCCase::EventProcessors::IssueProcessor do
  include MFCCase::EventProcessors::IssueProcessorSpecHelper

  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:new) }
  end

  describe '.new' do
    subject(:result) { described_class.new(c4s3, params) }

    let(:params) { nil }

    describe 'result' do
      subject { result }

      let(:c4s3) { create_case(:issuance, Time.now) }

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
      let(:c4s3) { create(:case) }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when case status is nil' do
      let(:c4s3) { create_case(nil, Time.now) }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when case status is not `issuance`' do
      let(:c4s3) { create_case('closed', Time.now) }

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

    let(:c4s3) { create_case(:issuance, Time.now) }
    let(:params) { {} }

    it { is_expected.to respond_to(:process) }
  end

  describe '#process' do
    subject { instance.process }

    let(:instance) { described_class.new(c4s3, params) }
    let(:c4s3) { create_case(:issuance, rejecting_expected_at) }
    let(:rejecting_expected_at) { Time.now + 24 * 60 * 60 }
    let(:params) { { operator_id: '123' } }

    it 'should set case status to `closed`' do
      expect { subject }.to change { case_status(c4s3) }.to('closed')
    end

    it 'should set `closed_at` case attribute to now' do
      subject
      expect(case_closed_at(c4s3)).to be_within(1).of(Time.now)
    end

    it 'should set `issuer_person_id` case attribute by params' do
      subject
      expect(case_issuer_person_id(c4s3))
        .to be == params[:operator_id] || params[:exported_id]
    end

    it 'should set `issued_at` case attribute to now' do
      subject
      expect(case_issued_at(c4s3)).to be_within(1).of(Time.now)
    end

    context 'when `rejecting_expected_at` attribute is absent' do
      let(:c4s3) { create(:case) }
      let!(:attrs) { create(:case_attributes, case: c4s3, status: 'issuance') }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when `rejecting_expected_at` attribute is nil' do
      let(:rejecting_expected_at) { nil }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when `rejecting_expected_at` attribute value is invalid' do
      let(:rejecting_expected_at) { 'invalid' }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when now date is more than value of `rejecting_expected_at`' do
      let(:rejecting_expected_at) { Time.now - 24 * 60 * 60 }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end
  end
end
