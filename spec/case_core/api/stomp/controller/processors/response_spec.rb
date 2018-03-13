# frozen_string_literal: true

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса
# `CaseCore::API::STOMP::Controller::Processors::Response`
# обработчиков сообщений STOMP, вызывающих действия
#

RSpec.describe CaseCore::API::STOMP::Controller::Processors::Response do
  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:new, :process) }
  end

  describe '.new' do
    subject { described_class.new(message) }

    let(:message) { create(:stomp_message) }

    it { is_expected.to be_a(described_class) }

    context 'when argument is not of `Stomp::Message` type' do
      let(:message) { 'not of `Stomp::Message` type' }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end

  describe '.process' do
    before { CaseCore::Logic::Loader.settings.dir = dir }

    subject(:result) { described_class.process(message) }

    let(:message) { create(:stomp_message) }
    let(:dir) { "#{$root}/spec/fixtures/logic" }

    context 'when argument is not of `Stomp::Message` type' do
      let(:message) { 'not of `Stomp::Message` type' }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    describe 'result' do
      subject { result }

      context 'when logic modules aren\'t loaded' do
        before do
          allow(CaseCore::Logic::Loader)
            .to receive(:loaded_logics)
            .and_return([])
        end

        it { is_expected.to be_falsey }
      end

      context 'when no logic has the handler' do
        before { test_logic }

        let(:test_logic) { CaseCore::Logic::Loader.logic('test_case') }

        it { is_expected.to be_falsey }
      end

      context 'when no logic can process the message' do
        before { allow(test_logic).to receive(handler_name).and_return(false) }

        let(:test_logic) { CaseCore::Logic::Loader.logic('test_case') }
        let(:handler_name) { described_class::HANDLER_NAME }

        it { is_expected.to be_falsey }
      end

      context 'when no logic can process the message without errors' do
        before { allow(test_logic).to receive(handler_name).and_raise('') }

        let(:test_logic) { CaseCore::Logic::Loader.logic('test_case') }
        let(:handler_name) { described_class::HANDLER_NAME }

        it { is_expected.to be_falsey }
      end

      context 'when there is a logic able to process' do
        before { allow(test_logic).to receive(handler_name).and_return(true) }

        let(:test_logic) { CaseCore::Logic::Loader.logic('test_case') }
        let(:handler_name) { described_class::HANDLER_NAME }

        it { is_expected.to be_truthy }
      end
    end
  end

  describe 'instance' do
    subject { described_class.new(message) }

    let(:message) { create(:stomp_message) }

    it { is_expected.to respond_to(:process) }
  end

  describe '#process' do
    before { CaseCore::Logic::Loader.settings.dir = dir }

    subject(:result) { instance.process }

    let(:instance) { described_class.new(message) }
    let(:message) { create(:stomp_message) }
    let(:dir) { "#{$root}/spec/fixtures/logic" }

    describe 'result' do
      subject { result }

      context 'when logic modules aren\'t loaded' do
        before do
          allow(CaseCore::Logic::Loader)
            .to receive(:loaded_logics)
            .and_return([])
        end

        it { is_expected.to be_falsey }
      end

      context 'when no logic has the handler' do
        before { test_logic }

        let(:test_logic) { CaseCore::Logic::Loader.logic('test_case') }

        it { is_expected.to be_falsey }
      end

      context 'when no logic can process the message' do
        before { allow(test_logic).to receive(handler_name).and_return(false) }

        let(:test_logic) { CaseCore::Logic::Loader.logic('test_case') }
        let(:handler_name) { described_class::HANDLER_NAME }

        it { is_expected.to be_falsey }
      end

      context 'when no logic can process the message without errors' do
        before { allow(test_logic).to receive(handler_name).and_raise('') }

        let(:test_logic) { CaseCore::Logic::Loader.logic('test_case') }
        let(:handler_name) { described_class::HANDLER_NAME }

        it { is_expected.to be_falsey }
      end

      context 'when there is a logic able to process' do
        before { allow(test_logic).to receive(handler_name).and_return(true) }

        let(:test_logic) { CaseCore::Logic::Loader.logic('test_case') }
        let(:handler_name) { described_class::HANDLER_NAME }

        it { is_expected.to be_truthy }
      end
    end
  end
end
