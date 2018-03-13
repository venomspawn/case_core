# frozen_string_literal: true

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования метода REST API, возвращающего информацию о версии
# приложения
#

RSpec.describe CaseCore::API::REST::Controller do
  describe 'GET /version' do
    include CaseCore::API::REST::Version::Show::SpecHelper

    subject { get '/version' }

    it { is_expected.to be_ok }
    it { is_expected.to have_proper_body(schema) }
  end
end
