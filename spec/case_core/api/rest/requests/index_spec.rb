# frozen_string_literal: true

# Файл тестирования метода REST API, возвращающего список с информацией о
# межведомственных запросах, созданных в рамках заявки

RSpec.describe CaseCore::API::REST::Controller do
  describe 'POST /cases/:id/requests' do
    subject { post "/cases/#{id}/requests", params.to_json }

    let(:params) { {} }
    let!(:c4s3) { create(:case) }
    let!(:requests) { create_list(:request, 2, case: c4s3) }
    let(:id) { c4s3.id }
    let(:schema) { CaseCore::Actions::Requests::Index::RESULT_SCHEMA }

    it { is_expected.to be_ok }
    it { is_expected.to have_proper_body(schema) }

    context 'when case record can\'t be found by provided id' do
      let(:id) { 'id' }

      it { is_expected.to be_not_found }
    end

    context 'when limit parameter is present' do
      let(:params) { { limit: limit } }

      context 'when value of the parameter is convertable to integer' do
        let(:limit) { 10 }

        it { is_expected.to be_ok }
      end

      context 'when value of the parameter isn\'t convertable to integer' do
        let(:limit) { 'abc' }

        it { is_expected.to be_unprocessable }
      end
    end

    context 'when offset parameter is present' do
      let(:params) { { offset: offset } }

      context 'when value of the parameter is convertable to integer' do
        let(:offset) { 10 }

        it { is_expected.to be_ok }
      end

      context 'when value of the parameter isn\'t convertable to integer' do
        let(:offset) { 'abc' }

        it { is_expected.to be_unprocessable }
      end
    end
  end
end
