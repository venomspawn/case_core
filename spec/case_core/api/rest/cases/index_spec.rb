# frozen_string_literal: true

# Тестирование метода REST API, возвращающего список с информацией о
# заявках

RSpec.describe CaseCore::API::REST::Controller do
  describe 'POST /cases' do
    subject { post '/cases', params.to_json }

    let!(:cases) { create_list(:case, 2) }
    let(:params) { {} }
    let(:schema) { CaseCore::Actions::Cases::Index::RESULT_SCHEMA }

    it { is_expected.to be_ok }
    it { is_expected.to have_proper_body(schema) }

    context 'when params are of wrong structure' do
      let(:params) { { filter: :wrong } }

      it { is_expected.to be_unprocessable }
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
