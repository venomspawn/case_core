# frozen_string_literal: true

# Тестирование функций модуля `CaseCore::Actions::Documents`

RSpec.describe CaseCore::Actions::Documents do
  subject { described_class }

  it { is_expected.to respond_to(:index, :create, :update) }

  describe '.index' do
    include described_class::Index::SpecHelper

    subject(:result) { described_class.index(params, rest) }

    let(:params) { { id: id } }
    let!(:c4s3) { create(:case, id: 'id') }
    let(:rest) { nil }

    it_should_behave_like 'an action parameters receiver',
                          params:          { id: 'id' },
                          wrong_structure: { wrong: :structure }

    describe 'result' do
      subject { result }

      let!(:documents) { create_list(:document, 2, case: c4s3) }
      let(:id) { c4s3.id }

      it { is_expected.to match_json_schema(schema) }
    end

    context 'when case record can\'t be found by provided id' do
      let(:id) { 'won\'t be found' }

      it 'should raise Sequel::NoMatchingRow' do
        expect { subject }.to raise_error(Sequel::NoMatchingRow)
      end
    end
  end

  it { is_expected.to respond_to(:create) }

  describe '.create' do
    subject { described_class.create(params, rest) }

    let(:params) { { case_id: case_id } }
    let(:case_id) { c4s3.id }
    let!(:c4s3) { create(:case, id: 'case_id') }
    let(:rest) { nil }

    it_should_behave_like 'an action parameters receiver',
                          params:          { id: 'id', case_id: 'case_id' },
                          wrong_structure: { wrong: :structure }

    it 'should create record of `CaseCore::Models::Document` model' do
      expect { subject }.to change { CaseCore::Models::Document.count }.by(1)
    end

    context 'when `id` attribute is not specified' do
      it 'should create value of the attribute' do
        expect { subject }.to change { CaseCore::Models::Document.count }.by(1)
      end
    end

    context 'when `id` attribute is specified' do
      let(:params) { { id: id, case_id: case_id } }
      let(:id) { 'id' }

      context 'when a record with the value exists' do
        let!(:document) { create(:document, id: :id, case_id: case_id) }

        it 'should raise Sequel::UniqueConstraintViolation' do
          expect { subject }.to raise_error(Sequel::UniqueConstraintViolation)
        end
      end

      context 'when a record with the value doesn\'t exist' do
        let(:document) { CaseCore::Models::Document.last }

        it 'should use specified value' do
          subject
          expect(document.id).to be == id
        end
      end
    end

    context 'when case record can\'t be found by provided id' do
      let(:case_id) { 'won\'t be found' }

      it 'should raise Sequel::ForeignKeyConstraintViolation' do
        expect { subject }
          .to raise_error(Sequel::ForeignKeyConstraintViolation)
      end
    end
  end

  it { is_expected.to respond_to(:update) }

  describe '.update' do
    subject { described_class.update(params, rest) }

    let(:params) { { id: id, case_id: case_id, title: new_title } }
    let(:case_id) { c4s3.id }
    let!(:c4s3) { create(:case, id: 'case_id') }
    let(:id) { document.id }
    let!(:document) { create(:document, traits) }
    let(:traits) { { case: c4s3, title: old_title, id: 'id' } }
    let(:old_title) { 'old_title' }
    let(:new_title) { 'new_title' }
    let(:rest) { nil }

    it_should_behave_like 'an action parameters receiver',
                          params:          { id: 'id', case_id: 'case_id' },
                          wrong_structure: { wrong: :structure }

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
