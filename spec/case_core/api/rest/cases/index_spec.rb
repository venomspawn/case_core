# frozen_string_literal: true

# Тестирование метода REST API, возвращающего список с информацией о
# заявках

RSpec.describe CaseCore::API::REST::Cases::Index do
  describe 'POST /cases' do
    include described_class::SpecHelper

    subject(:response) { post '/cases', params.to_json }

    let(:params) { {} }

    it 'should call `index` function of CaseCore::Actions::Cases' do
      expect(CaseCore::Actions::Cases).to receive(:index).and_call_original
      subject
    end

    describe 'response' do
      subject { response }

      let!(:cases) { create_list(:case, 2) }

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
end
