# frozen_string_literal: true

# Тестирование класса `CaseCore::Logic::Fetcher::Requests::LatestVersions`
# запросов к серверу библиотек на получение информации о последних версиях всех
# библиотек

RSpec.describe CaseCore::Logic::Fetcher::Requests::LatestVersions do
  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:latest_versions) }
  end

  describe '.latest_versions' do
    include described_class::SpecHelper

    before { stub_request(:get, /spec/).to_return(body: spec_body) }

    subject(:result) { described_class.latest_versions }

    let(:spec_body) { create_spec_body(info1, info2, info3) }
    let(:info1) { %w[test 0.0.1] }
    let(:info2) { %w[test 0.0.2] }
    let(:info3) { %w[t3st 0.0.1] }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(Hash) }

      context 'when no errors appear' do
        it 'should return information about latest versions' do
          expect(subject).to be == { 'test' => '0.0.2', 't3st' => '0.0.1' }
        end
      end

      context 'when an error appears during downloading the specs' do
        before { stub_request(:get, /spec/).to_return(status: 404) }

        it { is_expected.to be_empty }
      end

      context 'when an error appears during deserializing of the specs' do
        before { allow(Marshal).to receive(:load).and_raise }

        it { is_expected.to be_empty }
      end
    end
  end

  describe 'instance' do
    subject { described_class.new }

    it { is_expected.to respond_to(:latest_versions) }
  end

  describe '#latest_versions' do
    include described_class::SpecHelper

    before { stub_request(:get, /spec/).to_return(body: spec_body) }

    subject(:result) { instance.latest_versions }

    let(:instance) { described_class.new }
    let(:spec_body) { create_spec_body(info1, info2, info3) }
    let(:info1) { %w[test 0.0.1] }
    let(:info2) { %w[test 0.0.2] }
    let(:info3) { %w[t3st 0.0.1] }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(Hash) }

      context 'when no errors appear' do
        it 'should return information about latest versions' do
          expect(subject).to be == { 'test' => '0.0.2', 't3st' => '0.0.1' }
        end
      end

      context 'when an error appears during downloading the specs' do
        before { stub_request(:get, /spec/).to_return(status: 404) }

        it { is_expected.to be_empty }
      end

      context 'when an error appears during deserializing of the specs' do
        before { allow(Marshal).to receive(:load).and_raise }

        it { is_expected.to be_empty }
      end
    end
  end
end
