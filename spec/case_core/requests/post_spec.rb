# frozen_string_literal: true

# Файл тестирования подключаемого модуля `CaseCore::Requests::Post`

require "#{$lib}/requests/post"

RSpec.describe CaseCore::Requests::Post do
  subject(:instance) { Object.new.extend described_class }

  it 'should have private method `post`' do
    expect(subject.private_methods(false)).to include :post
  end

  describe '#post' do
    before { stub_request(:post, /example/).to_return(body: body) }

    subject { instance.send(:post, params) }

    let(:body) { 'body' }
    let(:params) { { url: url, payload: '' } }
    let(:url) { 'www.example.com' }

    it 'should make POST-request' do
      expect(subject.body).to be == body
    end

    context 'when `method` parameter is specified' do
      let(:params) { { method: :get, url: url } }

      it 'should be ignored' do
        subject
        expect(WebMock).to have_requested(:post, url)
      end
    end

    context 'when `url` parameter isn\'t specified' do
      let(:params) { { payload: '' } }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end
end
