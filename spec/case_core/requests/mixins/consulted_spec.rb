# frozen_string_literal: true

# Тестирование подключаемого модуля
# `CaseCore::Requests::Mixins::Consulted`

CaseCore.need 'requests/get'
CaseCore.need 'requests/mixins/consulted'

RSpec.describe CaseCore::Requests::Mixins::Consulted do
  before do
    stub_request(:get, /#{address}/).to_return(body: body)
    stub_request(:get, /#{service_address}/).to_return(body: body)
    stub_request(:get, /#{default_host}/).to_return(body: body)
    stub_request(:get, /service/).to_return(body: service_body, status: status)
    allow(instance).to receive(:service_name).and_return(service_name)
    allow(instance).to receive(:default_host).and_return(default_host)
    allow(instance).to receive(:default_port).and_return(default_port)
    allow(instance).to receive(:path).and_return(path)
  end

  subject { instance.send(:get) }

  let(:body) { '' }
  let(:service_body) { info.to_json }
  let(:info) { [**address_info, **service_address_info, **service_port_info] }
  let(:address_info) { { Address: address } }
  let(:address) { '1.2.3.4' }
  let(:service_address_info) { { ServiceAddress: service_address } }
  let(:service_address) { '4.3.2.1' }
  let(:service_port_info) { { ServicePort: service_port } }
  let(:service_port) { 1234 }
  let(:status) { 200 }
  let(:instance) { Object.new.extend(get_mixin).extend(described_class) }
  let(:get_mixin) { CaseCore::Requests::Get }
  let(:service_name) { 'test' }
  let(:default_host) { 'www.example.com' }
  let(:default_port) { 80 }
  let(:path) { '' }
  let(:url) { "#{service_address}:#{service_port}/#{path}" }

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

  context 'when service address info is blank' do
    let(:service_address) { '' }
    let(:url) { "#{address}:#{service_port}/#{path}" }

    it 'should use address info instead' do
      subject
      expect(WebMock).to have_requested(:get, url)
    end
  end

  context 'when an error happened during information download' do
    let(:status) { 404 }
    let(:url) { "#{default_host}:#{default_port}/#{path}" }

    it 'shouldn\'t raise any error' do
      expect { subject }.not_to raise_error
    end

    it 'should use default host and port values' do
      subject
      expect(WebMock).to have_requested(:get, url)
    end
  end
end
