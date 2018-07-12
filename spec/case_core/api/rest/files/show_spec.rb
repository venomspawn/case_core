# frozen_string_literal: true

# Тестирование метода REST API, извлекающего содержимое файла

RSpec.describe CaseCore::API::REST::Files::Show do
  describe 'GET /files/:id' do
    subject(:response) { get "/files/#{id}" }

    let(:id) { file.id }
    let(:file) { create(:file) }

    it 'should call `#show` of CaseCore::Actions::Files' do
      expect(CaseCore::Actions::Files).to receive(:show)
      subject
    end

    describe 'response' do
      subject { response }

      it { is_expected.to be_ok }

      it 'should contain file content as the body' do
        expect(subject.body) == file.content
      end

      context 'when id is not an UUID' do
        let(:id) { '123' }

        it { is_expected.to be_unprocessable }
      end

      context 'when file record is not found' do
        let(:id) { create(:uuid) }

        it { is_expected.to be_not_found }
      end
    end
  end
end
