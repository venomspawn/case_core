# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования функции `service` модуля `CaseCore::Consul`, возвращающей
# информацию о сервисе с заданным именем
#

require "#{$lib}/consul/service"

RSpec.describe CaseCore::Consul do
  describe 'the module' do
    subject { described_class }

    it { is_expected.to respond_to(:service) }
  end

  describe '.service' do
    before do
      stub_request(:get, /service/).to_return(body: body, status: status)
    end

    subject(:result) { described_class.service(name) }

    let(:body) { info.to_json }
    let(:info) { [Address: '1.2.3.4', ServiceAddress: '', ServicePort: 1234] }
    let(:status) { 200 }
    let(:name) { 'test' }

    describe 'result' do
      subject { result }

      it { is_expected.to be_an(OpenStruct) }

      attrs = %i(Address ServiceAddress ServicePort)
      it { is_expected.to respond_to(*attrs) }
    end

    context 'when an error happend during information download' do
      let(:status) { 404 }

      it 'should raise Diplomat::PathNotFound error' do
        expect { subject }.to raise_error(Diplomat::PathNotFound)
      end
    end
  end
end
