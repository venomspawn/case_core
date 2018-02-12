# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования модуля `MSPCase`, предоставляющего обработчики событий
# бизнес-логики МСП-услуги
#

CaseCore::Logic::Loader.instance.send(:unload_module, 'msp_case')
Object.send(:remove_const, :MSPCase) if Object.const_defined?(:MSPCase)

CaseCore::Logic::Loader.settings.dir = "#{$root}/logic"
CaseCore::Logic::Loader.logic('msp_case')

helpers_path = "#{$root}/spec/helpers/msp_case/event_processors"
load "#{helpers_path}/case_creation_processor_spec_helper.rb"
load "#{helpers_path}/change_status_to_processor_spec_helper.rb"
load "#{helpers_path}/responding_stomp_message_processor_spec_helper.rb"

RSpec.describe MSPCase do
  describe 'the module' do
    subject { described_class }

    event_processors = %i(
      on_case_creation
      on_responding_stomp_message
      change_status_to
    )

    it { is_expected.to respond_to(*event_processors) }
  end

  describe '.on_case_creation' do
    include MSPCase::EventProcessors::CaseCreationProcessorSpecHelper

    before do
      CaseCore::API::STOMP::Controller
        .instance
        .instance_variable_set('@publishers', nil)
      client = double
      allow(client).to receive(:publish)
      allow(Stomp::Client).to receive(:new).and_return(client)
    end

    subject { described_class.on_case_creation(c4s3) }

    let(:c4s3) { create(:case, type: 'msp_case') }

    it 'should set case status to `packaging`' do
      expect { subject }.to change { case_status(c4s3) }.to('processing')
    end

    it 'should create request record and associate it with the case record' do
      expect { subject }.to change { c4s3.requests_dataset.count }.by(1)
    end

    it 'should publish the created request' do
      client = double
      allow(client).to receive(:publish)
      allow(Stomp::Client).to receive(:new).and_return(client)

      expect(client).to receive(:publish)
      subject
    end

    describe 'created request record' do
      subject(:request) { c4s3.requests_dataset.order(:created_at.asc).last }

      it 'should have `msp_message_id` attribute' do
        described_class.on_case_creation(c4s3)
        expect(CaseCore::Actions::Requests.show(id: request.id))
          .to include('msp_message_id')
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

    context 'when case status is present' do
      let(:c4s3) { create(:case, type: 'msp_case') }
      let!(:case_attribute) { create(:case_attribute, *traits) }
      let(:traits) { [case: c4s3, name: 'status', value: 'status'] }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end
  end

  describe '.on_responding_stomp_message' do
    include MSPCase::EventProcessors::RespondingSTOMPMessageProcessorSpecHelper

    subject(:result) { described_class.on_responding_stomp_message(message) }

    let(:message) { create(:stomp_message, body: body) }
    let(:body) { data.to_json }
    let(:data) { { id: id, format: format, content: content } }
    let(:format) { 'EXCEPTION' }
    let(:content) { { special_data: special_data } }
    let(:id) { 'id' }
    let(:special_data) { '' }
    let!(:c4s3) { create_case(status, issue_location_type) }
    let(:status) { 'processing' }
    let(:issue_location_type) { 'mfc' }
    let!(:request) { create_request(c4s3, msp_message_id) }
    let(:msp_message_id) { id }

    describe 'result' do
      subject { result }

      it { is_expected.to be_truthy }

      context 'when `message` argument is not of `Stomp::Message` type' do
        let(:message) { 'not of `Stomp::Message` type' }

        it { is_expected.to be_falsey }
      end

      context 'when message body is not a JSON-string' do
        let(:message) { create(:stomp_message, body: body) }
        let(:body) { 'not a JSON-string' }

        it { is_expected.to be_falsey }
      end

      context 'when message body is a JSON-string of wrong structure' do
        let(:message) { create(:stomp_message, body: body) }
        let(:body) { wrong_structure.to_json }
        let(:wrong_structure) { { wrong: :structure } }

        it { is_expected.to be_falsey }
      end

      context 'when request record is not found by message id' do
        let(:msp_message_id) { 'won\'t be found' }

        it { is_expected.to be_falsey }
      end

      context 'when case has wrong type' do
        let(:c4s3) { create(:case, type: :wrong) }

        it { is_expected.to be_falsey }
      end

      context 'when case has wrong status' do
        let(:c4s3) { create_case('wrong', issue_location_type) }

        it { is_expected.to be_falsey }
      end
    end

    it 'should set `response_content` request attribute to incoming data' do
      expect { subject }
        .to change { request_response_content(request) }
        .to(special_data)
    end

    context 'when `format` field of the message is `EXCEPTION`' do
      let(:format) { 'EXCEPTION' }

      it 'should set case status to `error`' do
        expect { subject }.to change { case_status(c4s3) }.to('error')
      end
    end

    context 'when `format` field of the message is `REJECTION`' do
      let(:format) { 'REJECTION' }

      context 'when `issue_location_type` of case is not `email` nor `mfc`' do
        let(:issue_location_type) { 'not `email` nor `mfc`' }

        it 'shouldn\'t update attributes of the case' do
          expect { subject }.not_to change { case_attributes(c4s3.id) }
        end
      end

      context 'when `issue_location_type` of case is `email`' do
        let(:issue_location_type) { 'email' }

        it 'should set case status to `closed`' do
          expect { subject }.to change { case_status(c4s3) }.to('closed')
        end

        it 'should set `closed_at` case attribute to now' do
          subject
          expect(case_closed_at(c4s3)).to be_within(1).of(Time.now)
        end
      end

      context 'when `issue_location_type` of case is `mfc`' do
        let(:issue_location_type) { 'mfc' }

        it 'should set case status to `issuance`' do
          expect { subject }.to change { case_status(c4s3) }.to('issuance')
        end
      end
    end

    context 'when `format` field of the message is `RESPONSE`' do
      let(:format) { 'RESPONSE' }

      context 'when `issue_location_type` of case is not `email` nor `mfc`' do
        let(:issue_location_type) { 'not `email` nor `mfc`' }

        it 'shouldn\'t update attributes of the case' do
          expect { subject }.not_to change { case_attributes(c4s3.id) }
        end
      end

      context 'when `issue_location_type` of case is `email`' do
        let(:issue_location_type) { 'email' }

        it 'should set case status to `closed`' do
          expect { subject }.to change { case_status(c4s3) }.to('closed')
        end

        it 'should set `closed_at` case attribute to now' do
          subject
          expect(case_closed_at(c4s3)).to be_within(1).of(Time.now)
        end
      end

      context 'when `issue_location_type` of case is `mfc`' do
        let(:issue_location_type) { 'mfc' }

        it 'should set case status to `issuance`' do
          expect { subject }.to change { case_status(c4s3) }.to('issuance')
        end
      end
    end
  end

  describe '.change_status_to' do
    include MSPCase::EventProcessors::ChangeStatusToProcessorSpecHelper

    subject { described_class.change_status_to(c4s3, status, params) }

    let(:c4s3) { create_case('issuance') }
    let(:status) { 'closed' }
    let(:params) { {} }

    it 'should set case status to `closed`' do
      expect { subject }.to change { case_status(c4s3) }.to('closed')
    end

    it 'should set `closed_at` case attribute to now time' do
      subject
      expect(case_closed_at(c4s3)).to be_within(1).of(Time.now)
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

    context 'when case status is not `issuance`' do
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
end
