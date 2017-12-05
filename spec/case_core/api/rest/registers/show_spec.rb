# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования метода REST API, возвращающего информацию о реестре
# передаваемой корреспонденции с заданным идентификатором записи
#

RSpec.describe CaseCore::API::REST::Controller do
  describe 'GET /registers/:id' do
    subject { get "/registers/#{id}" }

    let!(:register) { create(:register, :with_cases) }
    let(:id) { register.id }
    let(:schema) { CaseCore::Actions::Registers::Show::RESULT_SCHEMA }

    it { is_expected.to be_ok }
    it { is_expected.to have_proper_body(schema) }

    context 'when case record can\'t be found by provided id' do
      let(:id) { 100_500 }

      it { is_expected.to be_not_found }
    end
  end
end
