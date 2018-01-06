# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса `MSPCase::EventProcessors::CaseCreationProcessor`
# обработчиков события создания заявки на МСП-услугу
#

CaseCore::Logic::Loader.instance.send(:unload_module, 'msp_case')
Object.send(:remove_const, :MSPCase) if Object.const_defined?(:MSPCase)

CaseCore::Logic::Loader.settings.dir = "#{$root}/logic"
CaseCore::Logic::Loader.logic('msp_case')

helpers_path = "#{$root}/spec/helpers/msp_case/event_processors"
load "#{helpers_path}/case_creation_processor_spec_helper.rb"

RSpec.describe MSPCase::EventProcessors::CaseCreationProcessor do
  include MSPCase::EventProcessors::CaseCreationProcessorSpecHelper

  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:new) }
  end

  describe '.new' do
    subject(:result) { described_class.new(c4s3) }

    describe 'result' do
      subject { result }

      let(:c4s3) { create(:case, type: 'msp_case') }

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
      let(:c4s3) { create(:case, type: 'msp_case') }
      let!(:case_attribute) { create(:case_attribute, *traits) }
      let(:traits) { [case: c4s3, name: 'status', value: 'status'] }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end
  end

  describe 'instance' do
    subject { described_class.new(c4s3) }

    let(:c4s3) { create(:case, type: 'msp_case') }

    it { is_expected.to respond_to(:process) }
  end

  describe '#process' do
    before do
      CaseCore::API::STOMP::Controller
        .instance
        .instance_variable_set('@publishers', nil)
      client = double
      allow(client).to receive(:publish)
      allow(Stomp::Client).to receive(:new).and_return(client)
    end

    subject { instance.process }

    let(:instance) { described_class.new(c4s3) }
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
        instance.process
        expect(CaseCore::Actions::Requests.show(id: request.id))
          .to include('msp_message_id')
      end
    end
  end
end
