# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования модуля `MFCCase`, предоставляющего обработчики событий
# бизнес-логики неавтоматизированной услуги
#

CaseCore::Logic::Loader.instance.send(:unload_module, 'mfc_case')
Object.send(:remove_const, :MFCCase) if Object.const_defined?(:MFCCase)

CaseCore::Logic::Loader.settings.dir = "#{$root}/logic"
CaseCore::Logic::Loader.logic('mfc_case')

helpers_path = "#{$root}/spec/helpers/mfc_case/event_processors"
load "#{helpers_path}/add_to_pending_list_processor_spec_helper.rb"
load "#{helpers_path}/case_creation_processor_spec_helper.rb"
load "#{helpers_path}/export_register_processor_spec_helper.rb"
load "#{helpers_path}/issue_processor_spec_helper.rb"
load "#{helpers_path}/reject_result_processor_spec_helper.rb"
load "#{helpers_path}/remove_from_pending_list_processor_spec_helper.rb"
load "#{helpers_path}/send_to_frontoffice_processor_spec_helper.rb"

RSpec.describe MFCCase do
  describe 'the module' do
    subject { described_class }

    event_processors = %i(
      add_to_pending_list
      export_register
      issue
      on_case_creation
      reject_result
      remove_from_pending_list
      send_to_frontoffice
    )

    it { is_expected.to respond_to(*event_processors) }
  end

  describe '.add_to_pending_list' do
    include MFCCase::EventProcessors::AddToPendingListProcessorSpecHelper

    subject { described_class.add_to_pending_list(c4s3, params) }

    let(:c4s3) { create_case(status) }
    let(:params) { { office_id: office_id } }
    let(:office_id) { create(:string) }

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
      let(:c4s3) { create_case(nil) }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when case status is not `packaging` nor `rejecting`' do
      let(:c4s3) { create_case('closed') }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when `params` argument is not of `NilClass` nor of `Hash` type' do
      let(:params) { 'not of `NilClass` nor of `Hash` type' }
      let(:c4s3) { create_case('packaging') }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when case status is `packaging`' do
      let(:status) { 'packaging' }

      it 'should set case status to `pending`' do
        expect { subject }.to change { case_status(c4s3) }.to('pending')
      end

      it 'should set `added_to_pending_at` attribute to current time' do
        subject
        expect(case_added_to_pending_at(c4s3)).to be_within(1).of(Time.now)
      end

      context 'when there is no appropriate register' do
        it 'should create one' do
          expect { subject }.to change { registers.count }.by(1)
        end

        it 'should link the case to the created register' do
          expect { subject }
            .to change { case_registers.where(case: c4s3).count }
            .by(1)
        end
      end

      context 'when there is appropriate register' do
        let!(:register) { create_appropriate_register(c4s3, office_id) }

        it 'shouldn\'t create any register' do
          expect { subject }.not_to change { registers.count }
        end

        it 'should link the case to the created register' do
          expect { subject }
            .to change { case_registers.where(case: c4s3).count }
            .by(1)
        end
      end
    end

    context 'when case status is `rejecting`' do
      let(:status) { 'rejecting' }

      it 'should set case status to `pending`' do
        expect { subject }.to change { case_status(c4s3) }.to('pending')
      end

      it 'should set `added_to_pending_at` attribute to current time' do
        subject
        expect(case_added_to_pending_at(c4s3)).to be_within(1).of(Time.now)
      end

      context 'when there is no appropriate register' do
        it 'should create one' do
          expect { subject }.to change { registers.count }.by(1)
        end

        it 'should link the case to the created register' do
          expect { subject }
            .to change { case_registers.where(case: c4s3).count }
            .by(1)
        end
      end

      context 'when there is appropriate register' do
        let!(:register) { create_appropriate_register(c4s3, office_id) }

        it 'shouldn\'t create any register' do
          expect { subject }.not_to change { registers.count }
        end

        it 'should link the case to the created register' do
          expect { subject }
            .to change { case_registers.where(case: c4s3).count }
            .by(1)
        end
      end
    end
  end

  describe '.export_register' do
    include MFCCase::EventProcessors::ExportRegisterProcessorSpecHelper

    subject { described_class.export_register(register, params) }

    let(:register) { create(:register) }
    let(:params) { { operator_id: '123' } }
    let(:c4s3) { create(:case) }
    let!(:link) { put_cases_into_register(register, c4s3) }
    let!(:attrs) { create(:case_attributes, case: c4s3, status: 'pending') }

    it 'should set `exported` attribute of the register to `true`' do
      subject
      expect(register.exported).to be_truthy
    end

    it 'should set `exported_at` attribute of the register to now' do
      subject
      expect(register.exported_at).to be_within(1).of(Time.now)
    end

    it 'should set `exporter_id` attribute of the register by params' do
      subject
      expect(register.exporter_id)
        .to be == params[:operator_id] || params[:exporter_id]
    end

    it 'should set `docs_sent_at` attribute of register\'s cases' do
      subject
      expect(case_docs_sent_at(c4s3)).to be_within(1).of(Time.now)
    end

    it 'should set `processor_person_id` attribute of register\'s cases' do
      subject
      expect(case_processor_person_id(c4s3))
        .to be == params[:operator_id] || params[:exporter_id]
    end

    it 'should set case status to `processing`' do
      subject
      expect(case_status(c4s3)).to be == 'processing'
    end

    context 'when `register` argument is of wrong type' do
      let(:register) { 'of wrong type' }
      let!(:link) {}

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when `params` argument is of wrong type' do
      let(:params) { 'of wrong type' }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when register is empty' do
      let(:link) {}

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when case has `issue_location_type` attribute' do
      context 'when the value of the attribute is `institution`' do
        let!(:more_attrs) { create(:case_attributes, case: c4s3, **traits) }
        let(:traits) {  { issue_location_type: 'institution' } }

        it 'should set case status to `closed`' do
          subject
          expect(case_status(c4s3)).to be == 'closed'
        end
      end
    end

    context 'when case has `added_to_rejecting_at` attribute' do
      context 'when the value of the attribute is present' do
        let!(:more_attrs) { create(:case_attributes, case: c4s3, **traits) }
        let(:traits) { { added_to_rejecting_at: Time.now } }

        it 'should set case status to `closed`' do
          subject
          expect(case_status(c4s3)).to be == 'closed'
        end
      end
    end

    context 'when there is attributeless case in the register' do
      let!(:attrs) {}

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when there is case in the register with absent status' do
      let!(:attrs) { create(:case_attributes, case: c4s3, stat: '') }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when there is case in the register with invalid status' do
      let!(:attrs) { create(:case_attributes, case: c4s3, status: 'invalid') }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end
  end

  describe '.issue' do
    include MFCCase::EventProcessors::IssueProcessorSpecHelper

    subject { described_class.issue(c4s3, params) }

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
      let(:c4s3) { create(:case, type: 'mfc_case') }
      let!(:attrs) { create(:case_attributes, case: c4s3, status: 'issuance') }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
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

    context 'when `rejecting_expected_at` attribute is nil' do
      let(:rejecting_expected_at) { nil }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when `rejecting_expected_at` attribute value is invalid' do
      let(:rejecting_expected_at) { 'invalid' }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when now date is more than value of `rejecting_expected_at`' do
      let(:rejecting_expected_at) { Time.now - 24 * 60 * 60 }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end
  end

  describe '.on_case_creation' do
    include MFCCase::EventProcessors::CaseCreationProcessorSpecHelper

    subject { described_class.on_case_creation(c4s3) }

    let(:c4s3) { create(:case, type: 'mfc_case') }

    it 'should set case status to `packaging`' do
      expect { subject }.to change { case_status(c4s3) }.to('packaging')
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

  describe '.reject_result' do
    include MFCCase::EventProcessors::RejectResultProcessorSpecHelper

    subject { described_class.reject_result(c4s3, params) }

    let(:c4s3) { create_case(:issuance, rejecting_expected_at) }
    let(:rejecting_expected_at) { Time.now - 24 * 60 * 60 }
    let(:params) { {} }

    it 'should set case status to `rejecting`' do
      expect { subject }.to change { case_status(c4s3) }.to('rejecting')
    end

    it 'should set `added_to_rejecting_at` case attribute to now' do
      subject
      expect(case_added_to_rejecting_at(c4s3)).to be_within(1).of(Time.now)
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

    context 'when `rejecting_expected_at` attribute is absent' do
      let(:c4s3) { create(:case, type: 'mfc_case') }
      let!(:attrs) { create(:case_attributes, case: c4s3, status: 'issuance') }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when `rejecting_expected_at` attribute is nil' do
      let(:rejecting_expected_at) { nil }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when `rejecting_expected_at` attribute value is invalid' do
      let(:rejecting_expected_at) { 'invalid' }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when now date is less than value of `rejecting_expected_at`' do
      let(:rejecting_expected_at) { Time.now + 24 * 60 * 60 }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end
  end

  describe '.remove_from_pending_list' do
    include MFCCase::EventProcessors::RemoveFromPendingListProcessorSpecHelper

    subject { described_class.remove_from_pending_list(c4s3, params) }

    let(:c4s3) { create_case(:pending, added_to_rejecting_at) }
    let(:added_to_rejecting_at) { nil }
    let(:params) { { operator_id: '123' } }

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

    context 'when the case in a register' do
      let(:register2) { create(:register) }
      let!(:link2) { put_cases_into_register(register2, c4s3) }
      let(:register) { create(:register) }
      let!(:link) { put_cases_into_register(register, c4s3) }

      it 'should remove the case from the register' do
        expect { subject }
          .to change { case_registers.with_pk([c4s3.id, register.id]) }
          .to(nil)
      end

      context 'when another older register contains the case' do
        it 'shouldn\'t remove the case from this older register' do
          expect { subject }
            .not_to change { case_registers.with_pk([c4s3.id, register2.id]) }
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
    end
  end

  describe '.send_to_frontoffice' do
    include MFCCase::EventProcessors::SendToFrontOfficeProcessorSpecHelper

    subject { described_class.send_to_frontoffice(c4s3, params) }

    let(:c4s3) { create_case(:processing) }
    let(:params) { { operator_id: 'operator_id', result_id: 'result_id' } }

    it 'should set case status to `issuance`' do
      expect { subject }.to change { case_status(c4s3) }.to('issuance')
    end

    it 'should set `responded_at` case attribute to now' do
      subject
      expect(case_responded_at(c4s3)).to be_within(1).of(Time.now)
    end

    it 'should set `response_processor_person_id` attribute by params' do
      subject
      expect(case_response_processor_person_id(c4s3))
        .to be == params[:operator_id]
    end

    it 'should set `result_id` attribute by params' do
      subject
      expect(case_result_id(c4s3)).to be == params[:result_id]
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
      let(:c4s3) { create_case(nil) }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when case status is not `processing`' do
      let(:c4s3) { create_case(:closed) }

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
end
