# frozen_string_literal: true

# Тестирование метода REST API, возвращающего информацию о заявке

RSpec.describe CaseCore::API::REST::Cases::Show do
  describe 'GET /cases/:id' do
    include described_class::SpecHelper

    subject(:response) { get "/cases/#{id}", params }

    let(:c4s3) { create(:case) }
    let(:id) { c4s3.id }
    let(:params) { {} }

    it 'should call `show` function of CaseCore::Actions::Cases' do
      expect(CaseCore::Actions::Cases).to receive(:show).and_call_original
      subject
    end

    describe 'response' do
      subject { response }

      it { is_expected.to be_ok }

      it { is_expected.to have_proper_body(schema) }

      context 'when case record can\'t be found by provided id' do
        let(:id) { 'id' }

        it { is_expected.to be_not_found }
      end

      context 'when parameter `names` is present' do
        let(:params) { { names: names } }

        context 'when the parameter\'s value is invalid' do
          let(:names) { { invalid: :value } }

          it { is_expected.to be_unprocessable }
        end
      end
    end
  end
end
