# frozen_string_literal: true

# Тестирование метода REST API, возвращающего информацию о версии
# приложения

RSpec.describe CaseCore::API::REST::Version::Show do
  include described_class::SpecHelper

  describe 'GET /version' do
    subject(:response) { get '/version' }

    describe 'response' do
      subject { response }

      it { is_expected.to be_ok }

      it { is_expected.to have_proper_body(schema) }
    end
  end
end
