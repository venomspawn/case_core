# frozen_string_literal: true

# Тестирование класса действия обновления записи документа

RSpec.describe CaseCore::Actions::Documents::Update do
  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:new) }
  end

  describe '.new' do
    subject(:result) { described_class.new(params, rest) }

    let(:params) { { id: :id, case_id: :case_id } }
    let(:rest) { nil }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(described_class) }
    end

    it_should_behave_like 'an action parameters receiver',
                          params:          { id: 'id', case_id: :case_id },
                          wrong_structure: { wrong: :structure }
  end

  describe 'instance' do
    subject { described_class.new(params) }

    let(:params) { { id: :id, case_id: :case_id } }

    it { is_expected.to respond_to(:update) }
  end

  describe '#update' do
    subject { instance.update }

    let(:instance) { described_class.new(params) }
    let(:params) { { id: id, case_id: case_id, title: new_title } }
    let(:case_id) { c4s3.id }
    let(:c4s3) { create(:case) }
    let(:id) { document.id }
    let(:document) { create(:document, case: c4s3, title: old_title) }
    let(:old_title) { 'old_title' }
    let(:new_title) { 'new_title' }

    it 'should update attributes of the record with provided id' do
      expect { subject }
        .to change { document.reload.title }
        .from(old_title)
        .to(new_title)
    end

    context 'when case record can\'t be found' do
      let(:case_id) { 'won\'t be found' }

      it 'should raise Sequel::NoMatchingRow' do
        expect { subject }.to raise_error(Sequel::NoMatchingRow)
      end
    end

    context 'when document record can\'t be found' do
      let(:id) { 'won\'t be found' }

      it 'should raise Sequel::NoMatchingRow' do
        expect { subject }.to raise_error(Sequel::NoMatchingRow)
      end
    end
  end
end
