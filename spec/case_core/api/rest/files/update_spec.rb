# frozen_string_literal: true

# Тестирование метода REST API, обновляющего содержимое файла

RSpec.describe CaseCore::API::REST::Files::Update do
  describe 'PUT /files/:id' do
    subject(:response) { put "/files/#{id}", body }

    let(:body) { 'body' }
    let(:id) { file.id }
    let(:file) { create(:file) }

    it 'should call `#update` of CaseCore::Actions::Files' do
      expect(CaseCore::Actions::Files).to receive(:update)
      subject
    end

    describe 'response' do
      subject { response }

      it { is_expected.to be_no_content }

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
