# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования метода REST API, возвращающего список с информацией о
# документах, прикреплённых к заявке
#

RSpec.describe CaseCore::API::REST::Controller do
  describe 'GET /cases/:id/documents' do
    subject { get "/cases/#{id}/documents" }

    let!(:c4s3) { create(:case) }
    let!(:documents) { create_list(:document, 2, case: c4s3) }

    let(:id) { c4s3.id }
    let(:schema) { CaseCore::Actions::Documents::Index::RESULT_SCHEMA }

    it { is_expected.to be_ok }
    it { is_expected.to have_proper_body(schema) }

    context 'when case record can\'t be found by provided id' do
      let(:id) { 'id' }

      it { is_expected.to be_not_found }
    end
  end
end
