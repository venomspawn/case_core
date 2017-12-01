# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования метода REST API, возвращающего список с информацией о
# реестрах передаваемой корреспонденции
#

RSpec.describe CaseCore::API::REST::Controller do
  describe 'GET /registers' do
    subject { get '/registers', params }

    let!(:registers) { create_list(:register, 2, :with_cases) }
    let(:params) { {} }
    let(:schema) { CaseCore::Actions::Registers::Index::RESULT_SCHEMA }

    it { is_expected.to be_ok }
    it { is_expected.to have_proper_body(schema) }

    context 'when params are of wrong structure' do
      let(:params) { { filter: :wrong } }

      it { is_expected.to be_unprocessable }
    end
  end
end
