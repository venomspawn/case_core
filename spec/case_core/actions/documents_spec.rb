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

      let!(:absent) { create_list(:document, 2, case: c4s3) }
      let!(:provided) { create_list(:document, 2, :with_scan, case: c4s3) }
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

    params_selector = proc do |selector|
      next { wrong: :structure } if selector == :wrong_structure
      { id: 'id', case_id: 'case_id', fs_id: FactoryBot.create(:file).id }
    end
    it_should_behave_like 'an action parameters receiver', params_selector

    it 'should create record of `CaseCore::Models::Document` model' do
      expect { subject }.to change { CaseCore::Models::Document.count }.by(1)
    end

    context 'when `id` attribute is not specified' do
      it 'should create value of the attribute' do
        expect { subject }.to change { CaseCore::Models::Document.count }.by(1)
      end
    end

    context 'when `provided` is `true` and `fs_id` is proper' do
      let(:params) { { case_id: case_id, provided: true, fs_id: file.id } }
      let(:file) { create(:file) }

      it 'should create record of `CaseCore::Models::Scan` model' do
        expect { subject }.to change { CaseCore::Models::Scan.count }.by(1)
      end
    end

    context 'when `provided` is `false`' do
      let(:params) { { case_id: case_id, provided: false, fs_id: file.id } }
      let(:file) { create(:file) }

      it 'shouldn\'t create record of `CaseCore::Models::Scan` model' do
        expect { subject }.to change { CaseCore::Models::Scan.count }.by(0)
      end
    end

    context 'when `provided` is `nil`' do
      let(:params) { { case_id: case_id, provided: nil, fs_id: file.id } }
      let(:file) { create(:file) }

      it 'shouldn\'t create record of `CaseCore::Models::Scan` model' do
        expect { subject }.to change { CaseCore::Models::Scan.count }.by(0)
      end
    end

    context 'when `provided` is absent' do
      let(:params) { { case_id: case_id, fs_id: file.id } }
      let(:file) { create(:file) }

      it 'shouldn\'t create record of `CaseCore::Models::Scan` model' do
        expect { subject }.to change { CaseCore::Models::Scan.count }.by(0)
      end
    end

    context 'when `fs_id` is absent' do
      let(:params) { { case_id: case_id, provided: true } }

      it 'shouldn\'t create record of `CaseCore::Models::Scan` model' do
        expect { subject }.to change { CaseCore::Models::Scan.count }.by(0)
      end
    end

    context 'when `id` attribute is specified' do
      let(:params) { { id: id, case_id: case_id, fs_id: create(:file).id } }
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

    let(:params) { { id: id, case_id: case_id, size: new_size } }
    let(:case_id) { c4s3.id }
    let!(:c4s3) { create(:case, id: 'case_id') }
    let(:id) { document.id }
    let!(:document) { create(:document, traits) }
    let(:traits) { { case: c4s3, scan_id: scan_id, id: 'id' } }
    let(:scan_id) { scan.id }
    let(:scan) { create(:scan, size: old_size) }
    let(:old_size) { 'old_size' }
    let(:new_size) { 'new_size' }
    let(:rest) { nil }

    it_should_behave_like 'an action parameters receiver',
                          params:          { id: 'id', case_id: 'case_id' },
                          wrong_structure: { wrong: :structure }

    it 'should update attributes of the scan of the document' do
      expect { subject }
        .to change { scan.reload.size }
        .from(old_size)
        .to(new_size)
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

    context 'when document doesn\'t have a scan' do
      let(:scan_id) { nil }

      it 'should raise Sequel::NoMatchingRow' do
        expect { subject }.to raise_error(Sequel::NoMatchingRow)
      end
    end
  end
end
