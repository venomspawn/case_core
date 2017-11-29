# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования метода REST API, возвращающего список с информацией о
# заявках
#

RSpec.describe CaseCore::API::REST::Application do
  describe 'GET /cases' do
    subject { get '/cases', params }

    let!(:cases) { create_list(:case, 2) }
    let(:params) { {} }
    let(:schema) { CaseCore::Actions::Cases::Index::RESULT_SCHEMA }

    it { is_expected.to be_ok }
    it { is_expected.to have_proper_body(schema) }

    context 'when params are of wrong structure' do
      let(:params) { { filter: :wrong } }

      it { is_expected.to be_unprocessable }
    end
  end
end
