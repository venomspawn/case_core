# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования модели документа `CaseCore::Models::Document`
#

RSpec.describe CaseCore::Models::Document do
  describe 'the model' do
    subject { described_class }

    it { is_expected.to respond_to(:create) }
  end

  describe '.create' do
    subject(:result) { described_class.create(params) }

    let(:params) { { id: id, case: c4s3 } }
    let(:c4s3) { create(:case) }
    let(:id) { create(:string) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(described_class) }
    end

    context 'when id is not specified' do
      let(:params) { { case: c4s3 } }

      it 'should raise Sequel::NotNullConstraintViolation' do
        expect { subject }.to raise_error(Sequel::NotNullConstraintViolation)
      end
    end

    context 'when id is nil' do
      let(:params) { { id: nil, case: c4s3 } }

      it 'should raise Sequel::InvalidValue' do
        expect { subject }.to raise_error(Sequel::InvalidValue)
      end
    end

    context 'when id is used by another record' do
      let(:document) { create(:document) }
      let(:id) { document.id }

      it 'should raise Sequel::UniqueConstraintViolation' do
        expect { subject }.to raise_error(Sequel::UniqueConstraintViolation)
      end
    end

    context 'when case or case id are not specified' do
      let(:params) { { id: id } }

      it 'should raise Sequel::NotNullConstraintViolation' do
        expect { subject }.to raise_error(Sequel::NotNullConstraintViolation)
      end
    end

    context 'when case is nil' do
      let(:params) { { id: id, case: nil } }

      it 'should raise Sequel::InvalidValue' do
        expect { subject }.to raise_error(Sequel::InvalidValue)
      end
    end

    context 'when case_id is nil' do
      let(:params) { { id: id, case_id: nil } }

      it 'should raise Sequel::InvalidValue' do
        expect { subject }.to raise_error(Sequel::InvalidValue)
      end
    end

    context 'when direction is not `input` or `output`' do
      let(:params) { { id: id, case: c4s3, direction: 'wrong' } }

      it 'should raise Sequel::DatabaseError' do
        expect { subject }.to raise_error(Sequel::DatabaseError)
      end
    end

    context 'when provided_as is wrong' do
      let(:params) { { id: id, case: c4s3, provided_as: 'wrong' } }

      it 'should raise Sequel::DatabaseError' do
        expect { subject }.to raise_error(Sequel::DatabaseError)
      end
    end
  end

  describe 'instance of the model' do
    subject(:instance) { create(:document) }

    methods = %i(
      case
      case_id
      correct
      created_at
      direction
      filename
      fs_id
      id
      in_document_id
      last_modified
      mime_type
      provided
      provided_as
      quantity
      size
      title
      update
    )
    it { is_expected.to respond_to(*methods) }
  end

  describe '#case' do
    subject(:result) { instance.case }

    let(:instance) { create(:document) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(CaseCore::Models::Case) }

      it 'should be a record this records belongs to' do
        expect(subject.id).to be == instance.case_id
      end
    end
  end

  describe '#case_id' do
    subject(:result) { instance.case_id }

    let(:instance) { create(:document) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(String) }
    end
  end

  describe '#correct' do
    subject(:result) { instance.correct }

    let(:instance) { create(:document) }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is present' do
        it 'should be boolean' do
          expect(subject).to be_truthy.or be_falsey
        end
      end

      context 'when value of the corresponding field is absent' do
        let(:instance) { create(:document, correct: nil) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#created_at' do
    subject(:result) { instance.created_at }

    let(:instance) { create(:document) }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is present' do
        it { is_expected.to be_a(Time) }
      end

      context 'when value of the corresponding field is absent' do
        let(:instance) { create(:document, created_at: nil) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#direction' do
    subject(:result) { instance.direction }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is `input`' do
        let(:instance) { create(:document, direction: 'input') }

        it { is_expected.to be == 'input' }
      end

      context 'when value of the corresponding field is `output`' do
        let(:instance) { create(:document, direction: 'output') }

        it { is_expected.to be == 'output' }
      end

      context 'when value of the corresponding field is absent' do
        let(:instance) { create(:document, direction: nil) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#filename' do
    subject(:result) { instance.filename }

    let(:instance) { create(:document) }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is present' do
        it { is_expected.to be_a(String) }
      end

      context 'when value of the corresponding field is absent' do
        let(:instance) { create(:document, filename: nil) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#fs_id' do
    subject(:result) { instance.fs_id }

    let(:instance) { create(:document) }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is present' do
        it { is_expected.to be_a(String) }
      end

      context 'when value of the corresponding field is absent' do
        let(:instance) { create(:document, fs_id: nil) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#id' do
    subject(:result) { instance.id }

    let(:instance) { create(:document) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(String) }
    end
  end

  describe '#in_document_id' do
    subject(:result) { instance.in_document_id }

    let(:instance) { create(:document) }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is present' do
        it { is_expected.to be_a(String) }
      end

      context 'when value of the corresponding field is absent' do
        let(:instance) { create(:document, in_document_id: nil) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#last_modified' do
    subject(:result) { instance.last_modified }

    let(:instance) { create(:document) }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is present' do
        it { is_expected.to be_a(String) }
      end

      context 'when value of the corresponding field is absent' do
        let(:instance) { create(:document, last_modified: nil) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#mime_type' do
    subject(:result) { instance.mime_type }

    let(:instance) { create(:document) }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is present' do
        it { is_expected.to be_a(String) }
      end

      context 'when value of the corresponding field is absent' do
        let(:instance) { create(:document, mime_type: nil) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#provided' do
    subject(:result) { instance.provided }

    let(:instance) { create(:document) }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is present' do
        it 'should be boolean' do
          expect(subject).to be_truthy.or be_falsey
        end
      end

      context 'when value of the corresponding field is absent' do
        let(:instance) { create(:document, provided: nil) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#provided_as' do
    subject(:result) { instance.provided_as }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is `original`' do
        let(:instance) { create(:document, provided_as: 'original') }

        it { is_expected.to be == 'original' }
      end

      context 'when value of the corresponding field is `copy`' do
        let(:instance) { create(:document, provided_as: 'copy') }

        it { is_expected.to be == 'copy' }
      end

      context 'when value of the corresponding field is `notarized_copy`' do
        let(:instance) { create(:document, provided_as: 'notarized_copy') }

        it { is_expected.to be == 'notarized_copy' }
      end

      context 'when value of the corresponding field is `doc_list`' do
        let(:instance) { create(:document, provided_as: 'doc_list') }

        it { is_expected.to be == 'doc_list' }
      end

      context 'when value of the corresponding field is absent' do
        let(:instance) { create(:document, provided_as: nil) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#quantity' do
    subject(:result) { instance.quantity }

    let(:instance) { create(:document) }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is present' do
        it { is_expected.to be_an(Integer) }
      end

      context 'when value of the corresponding field is absent' do
        let(:instance) { create(:document, quantity: nil) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#size' do
    subject(:result) { instance.size }

    let(:instance) { create(:document) }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is present' do
        it { is_expected.to be_a(String) }
      end

      context 'when value of the corresponding field is absent' do
        let(:instance) { create(:document, size: nil) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#title' do
    subject(:result) { instance.title }

    let(:instance) { create(:document) }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is present' do
        it { is_expected.to be_a(String) }
      end

      context 'when value of the corresponding field is absent' do
        let(:instance) { create(:document, title: nil) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#update' do
    subject { instance.update(params) }

    let(:instance) { create(:document) }

    context 'when id is specified' do
      let(:params) { { id: create(:string) } }

      it 'should raise Sequel::MassAssignmentRestriction' do
        expect { subject }.to raise_error(Sequel::MassAssignmentRestriction)
      end
    end

    context 'when case is specified and `nil`' do
      let(:params) { { case: nil } }

      it 'should raise Sequel::InvalidValue' do
        expect { subject }.to raise_error(Sequel::InvalidValue)
      end
    end

    context 'when case_id is specified and `nil`' do
      let(:params) { { case_id: nil } }

      it 'should raise Sequel::InvalidValue' do
        expect { subject }.to raise_error(Sequel::InvalidValue)
      end
    end
  end
end
