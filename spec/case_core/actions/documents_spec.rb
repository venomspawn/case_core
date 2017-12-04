# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования функций модуля `CaseCore::Actions::Documents`
#

RSpec.describe CaseCore::Actions::Documents do
  subject { described_class }

  it { is_expected.to respond_to(:index) }

  describe '.index' do
    subject(:result) { described_class.index(params) }

    let(:params) { { id: id } }

    describe 'result' do
      subject { result }

      let!(:c4s3) { create(:case) }
      let!(:documents) { create_list(:document, 2, case: c4s3) }
      let(:id) { c4s3.id }
      let(:schema) { described_class::Index::RESULT_SCHEMA }

      it { is_expected.to match_json_schema(schema) }
    end

    context 'when argument is not of Hash type' do
      let(:params) { 'not of Hash type' }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end

    context 'when argument is of Hash type but doesn\'t have `id` attribute' do
      let(:params) { { doesnt: :have_id_attribute } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
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
    subject { described_class.create(params) }

    let(:params) { { case_id: case_id } }
    let(:case_id) { c4s3.id }
    let(:c4s3) { create(:case) }

    it 'should create record of `CaseCore::Models::Document` model' do
      expect { subject }.to change { CaseCore::Models::Document.count }.by(1)
    end

    context 'when argument is not of Hash type' do
      let(:params) { 'not of Hash type' }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end

    context 'when argument is of Hash type but is of wrong structure' do
      let(:params) { { wrong: :structure } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
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
end
