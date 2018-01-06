# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса
# `MSPCase::EventProcessors::RespondingSTOMPMessageProcessor` обработчиков
# события `responding_stomp_message` при получении ответного STOMP-сообщения
# на запрос МСП-услуги
#

CaseCore::Logic::Loader.instance.send(:unload_module, 'msp_case')
Object.send(:remove_const, :MSPCase) if Object.const_defined?(:MSPCase)

CaseCore::Logic::Loader.settings.dir = "#{$root}/logic"
CaseCore::Logic::Loader.logic('msp_case')

helpers_path = "#{$root}/spec/helpers/msp_case/event_processors"
load "#{helpers_path}/responding_stomp_message_processor_spec_helper.rb"

RSpec.describe MSPCase::EventProcessors::RespondingSTOMPMessageProcessor do
  include MSPCase::EventProcessors::RespondingSTOMPMessageProcessorSpecHelper

  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:new) }
  end

  describe '.new' do
    subject(:result) { described_class.new(message) }

    describe 'result' do
      subject { result }

      let(:message) { create(:stomp_message, body: body) }
      let(:body) { data.to_json }
      let(:data) { { id: :id, format: :EXCEPTION, content: content } }
      let(:content) { { special_data: '' } }

      it { is_expected.to be_an_instance_of(described_class) }
    end

    context 'when `message` argument is not of `Stomp::Message` type' do
      let(:message) { 'not of `Stomp::Message` type' }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when message body is not a JSON-string' do
      let(:message) { create(:stomp_message, body: body) }
      let(:body) { 'not a JSON-string' }

      it 'should raise JSON::ParserError' do
        expect { subject }.to raise_error(JSON::ParserError)
      end
    end

    context 'when message body is a JSON-string of wrong structure' do
      let(:message) { create(:stomp_message, body: body) }
      let(:body) { wrong_structure.to_json }
      let(:wrong_structure) { { wrong: :structure } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end
  end

  describe 'instance' do
    subject { described_class.new(message) }

    let(:message) { create(:stomp_message, body: body) }
    let(:body) { data.to_json }
    let(:data) { { id: :id, format: :EXCEPTION, content: content } }
    let(:content) { { special_data: '' } }

    it { is_expected.to respond_to(:process) }
  end

  describe '#process' do
    subject { instance.process }

    let(:instance) { described_class.new(message) }
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

    it 'should set `response_content` request attribute to incoming data' do
      expect { subject }
        .to change { request_response_content(request) }
        .to(special_data)
    end

    context 'when request record is not found by message id' do
      let(:msp_message_id) { 'won\'t be found' }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when case has wrong type' do
      let(:c4s3) { create(:case, type: :wrong) }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when case has wrong status' do
      let(:c4s3) { create_case('wrong', issue_location_type) }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
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
end
