# frozen_string_literal: true

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования подключаемого модуля `CaseCore::Requests::Get`
#

require "#{$lib}/requests/get"

RSpec.describe CaseCore::Requests::Get do
  subject(:instance) { Object.new.extend described_class }

  it 'should have private method `get`' do
    expect(subject.private_methods(false)).to include :get
  end

  describe '#get' do
    before { stub_request(:get, /example/).to_return(body: body) }

    subject { instance.send(:get, params) }

    let(:body) { 'body' }
    let(:params) { { url: url } }
    let(:url) { 'www.example.com' }

    it 'should make GET-request' do
      expect(subject.body).to be == body
    end

    context 'when `method` parameter is specified' do
      let(:params) { { method: :post, url: url } }

      it 'should be ignored' do
        subject
        expect(WebMock).to have_requested(:get, url)
      end
    end

    context 'when `url` parameter isn\'t specified' do
      let(:params) { {} }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end
end
