# frozen_string_literal: true

# Тестирование метода REST API, возвращающего список с информацией о
# документах, прикреплённых к заявке

RSpec.describe CaseCore::API::REST::Documents::Index do
  include described_class::SpecHelper

  describe 'GET /cases/:id/documents' do
    subject(:response) { get "/cases/#{id}/documents" }

    let(:c4s3) { create(:case) }
    let!(:documents) { create_list(:document, 2, case: c4s3) }
    let(:id) { c4s3.id }

    it 'should call `index` function of CaseCore::Actions::Documents' do
      expect(CaseCore::Actions::Documents).to receive(:index).and_call_original
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
    end
  end
end
