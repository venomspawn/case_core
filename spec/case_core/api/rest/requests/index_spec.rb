# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования метода REST API, возвращающего список с информацией о
# межведомственных запросах, созданных в рамках заявки
#

RSpec.describe CaseCore::API::REST::Controller do
  describe 'GET /cases/:id/requests' do
    subject { get "/cases/#{id}/requests" }

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
  end
end
