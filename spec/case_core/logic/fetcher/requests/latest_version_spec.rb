# frozen_string_literal: true

# Тестирование класса `CaseCore::Logic::Fetcher::Requests::LatestVersion`
# запросов к серверу библиотек на получение информации о последней версии
# библиотеки с заданным названием

RSpec.describe CaseCore::Logic::Fetcher::Requests::LatestVersion do
  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:latest_version) }
  end

  describe '.latest_version' do
    include described_class::SpecHelper

    before { stub_request(:get, /spec/).to_return(body: spec_body) }

    subject(:result) { described_class.latest_version(name) }

    let(:spec_body) { create_spec_body([name, version]) }
    let(:name) { 'test' }
    let(:version) { '0.0.1' }

    describe 'result' do
      subject { result }

      context 'when the library is found' do
        context 'when no errors appear' do
          it { is_expected.to be == version }
        end

        context 'when an error appears during downloading the specs' do
          before { stub_request(:get, /spec/).to_return(status: 404) }

          it { is_expected.to be_nil }
        end

        context 'when an error appears during deserializing of the specs' do
          before { allow(Marshal).to receive(:load).and_raise }

          it { is_expected.to be_nil }
        end
      end

      context 'when the library is not found' do
        let(:spec_body) { create_spec_body }

        it { is_expected.to be_nil }
      end
    end
  end

  describe 'instance' do
    subject { described_class.new(name) }

    let(:name) { 'test' }

    it { is_expected.to respond_to(:latest_version) }
  end

  describe '#latest_version' do
    include described_class::SpecHelper

    before { stub_request(:get, /spec/).to_return(body: spec_body) }

    subject(:result) { instance.latest_version }

    let(:instance) { described_class.new(name) }
    let(:spec_body) { create_spec_body([name, version]) }
    let(:name) { 'test' }
    let(:version) { '0.0.1' }

    describe 'result' do
      subject { result }

      context 'when the library is found' do
        context 'when no errors appear' do
          it { is_expected.to be == version }
        end

        context 'when an error appears during downloading the specs' do
          before { stub_request(:get, /spec/).to_return(status: 404) }

          it { is_expected.to be_nil }
        end

        context 'when an error appears during deserializing of the specs' do
          before { allow(Marshal).to receive(:load).and_raise }

          it { is_expected.to be_nil }
        end
      end

      context 'when the library is not found' do
        let(:spec_body) { create_spec_body }

        it { is_expected.to be_nil }
      end
    end
  end
end
