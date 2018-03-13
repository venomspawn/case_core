# frozen_string_literal: true

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования подключаемого модуля `CaseCore::Requests::Mixins::URL`
#

require "#{$lib}/requests/get"
require "#{$lib}/requests/mixins/url"

RSpec.describe CaseCore::Requests::Mixins::URL do
  before do
    stub_request(:get, /example/).to_return(body: body)
    allow(instance).to receive(:host).and_return(host)
    allow(instance).to receive(:port).and_return(port)
    allow(instance).to receive(:path).and_return(path)
  end

  subject { instance.send(:get) }

  let(:instance) { Object.new.extend(get_mixin).extend(described_class) }
  let(:get_mixin) { CaseCore::Requests::Get }
  let(:body) { '' }
  let(:host) { 'www.example.com' }
  let(:port) { 80 }
  let(:path) { '' }
  let(:url) { "#{host}:#{port}/#{path}" }

  it 'should create URL and use it in request' do
    subject
    expect(WebMock).to have_requested(:get, url)
  end

  context 'when `url` parameter is specified' do
    subject { instance.send(:get, url: 'www.h4xx0r.com') }

    it 'should ignore it' do
      subject
      expect(WebMock).to have_requested(:get, url)
    end
  end
end
