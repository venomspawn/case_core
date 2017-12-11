# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса `CaseCore::Logic::Fetcher::GemRequest` запросов к
# серверу библиотек на получение тела файла библиотеки с заданными названием и
# версией
#

RSpec.describe CaseCore::Logic::Fetcher::GemRequest do
  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:gem) }
  end

  describe '.gem' do
    before { stub_request(:get, /gem/).to_return(body: gem_body) }

    subject(:result) { described_class.gem(name, version) }

    let(:gem_body) { '' }
    let(:name) { 'test' }
    let(:version) { '0.0.1' }

    describe 'result' do
      context 'when no errors appear' do
        it { is_expected.to be_a(String) }
      end

      context 'when an error appears during downloading' do
        before { stub_request(:get, /gem/).to_return(status: 404) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe 'instance' do
    subject { described_class.new(name, version) }

    let(:name) { 'test' }
    let(:version) { '0.0.1' }

    it { is_expected.to respond_to(:gem) }
  end

  describe '#gem' do
    before { stub_request(:get, /gem/).to_return(body: gem_body) }

    subject(:result) { instance.gem }

    let(:instance) { described_class.new(name, version) }
    let(:gem_body) { '' }
    let(:name) { 'test' }
    let(:version) { '0.0.1' }

    describe 'result' do
      context 'when no errors appear' do
        it { is_expected.to be_a(String) }
      end

      context 'when an error appears during downloading' do
        before { stub_request(:get, /gem/).to_return(status: 404) }

        it { is_expected.to be_nil }
      end
    end
  end
end
