# frozen_string_literal: true

# Файл тестирования метода REST API, возвращающего информацию о заявке

RSpec.describe CaseCore::API::REST::Controller do
  describe 'GET /cases/:id' do
    subject { get "/cases/#{id}" }

    let!(:c4s3) { create(:case) }
    let(:id) { c4s3.id }
    let(:schema) { CaseCore::Actions::Cases::Show::RESULT_SCHEMA }

    it { is_expected.to be_ok }
    it { is_expected.to have_proper_body(schema) }

    context 'when case record can\'t be found by provided id' do
      let(:id) { 'id' }

      it { is_expected.to be_not_found }
    end
  end
end
