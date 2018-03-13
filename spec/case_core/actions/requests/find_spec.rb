# frozen_string_literal: true

# Файл тестирования класса `CaseCore::Actions::Requests::Find` действия
# поиска записи межведомственного запроса по предоставленным атрибутам

RSpec.describe CaseCore::Actions::Requests::Find do
  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:new) }
  end

  describe '.new' do
    subject(:result) { described_class.new(params) }

    let(:params) { {} }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(described_class) }
    end

    context 'when argument is not of Hash type' do
      let(:params) { 'not of Hash type' }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end
  end

  describe 'instance' do
    subject { described_class.new(params) }

    let(:params) { {} }

    it { is_expected.to respond_to(:find) }
  end

  describe '#find' do
    subject(:result) { instance.find }

    let(:instance) { described_class.new(params) }
    let(:params) { {} }
    let(:requests_dataset) { CaseCore::Models::Request.dataset }

    describe 'result' do
      subject { result }

      context 'when no attributes are specified' do
        context 'when there are no request records' do
          it { is_expected.to be_nil }
        end

        context 'when there are request records' do
          let!(:requests) { create_list(:request, 2) }

          it { is_expected.to be_a(CaseCore::Models::Request) }

          it 'should be last created one' do
            expect(result)
              .to be == requests_dataset.order_by(:created_at.desc).first
          end
        end
      end

      context 'when attributes are specified' do
        let(:params) { { name => value } }
        let(:name) { 'name' }
        let(:value) { 'value' }

        context 'when there are no request records' do
          it { is_expected.to be_nil }
        end

        context 'when there are request records' do
          let!(:requests) { create_list(:request, 2) }

          context 'when there is no record with the attributes' do
            it { is_expected.to be_nil }
          end

          context 'when there are records with the attributes' do
            let!(:attr1) { create(:request_attribute, *traits1) }
            let(:traits1) { [request: request1, name: name, value: value] }
            let(:request1) { requests.first }
            let!(:attr2) { create(:request_attribute, *traits2) }
            let(:traits2) { [request: request2, name: name, value: value] }
            let(:request2) { requests.last }

            it { is_expected.to be_a(CaseCore::Models::Request) }

            it 'should be last created one with the attributes' do
              expect(result)
                .to be == requests_dataset.order_by(:created_at.desc).first
            end
          end
        end
      end
    end
  end
end
