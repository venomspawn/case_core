# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования метода REST API, возвращающего информацию о количестве
# заявок
#

RSpec.describe CaseCore::API::REST::Controller do
  describe 'GET /cases_count' do
    subject { get '/cases_count', params }

    let!(:cases) { create_list(:case, 2) }
    let(:params) { {} }
    let(:schema) { CaseCore::Actions::Cases::Count::RESULT_SCHEMA }

    it { is_expected.to be_ok }
    it { is_expected.to have_proper_body(schema) }

    context 'when params are of wrong structure' do
      let(:params) { { filter: :wrong } }

      it { is_expected.to be_unprocessable }
    end
  end
end
