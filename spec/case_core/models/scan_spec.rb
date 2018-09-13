# frozen_string_literal: true

# Тестирование модели электронной копии документа `CaseCore::Models::Scan`

RSpec.describe CaseCore::Models::Scan do
  describe 'the model' do
    subject { described_class }

    it { is_expected.to respond_to(:new, :create) }
  end

  describe '.new' do
    subject(:result) { described_class.new(params) }

    describe 'result' do
      subject { result }

      let(:params) { {} }

      it { is_expected.to be_an_instance_of(described_class) }
    end
  end

  describe '.create' do
    subject(:result) { described_class.create(params) }

    let(:params) { attributes_for(:scan) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(described_class) }
    end

    context 'when id is specified' do
      let(:params) { attributes_for(:scan, id: 1) }

      it 'should raise Sequel::MassAssignmentRestriction' do
        expect { subject }.to raise_error(Sequel::MassAssignmentRestriction)
      end
    end

    context 'when direction is not `input` or `output`' do
      let(:params) { attributes_for(:scan, direction: 'wrong') }

      it 'should raise Sequel::DatabaseError' do
        expect { subject }.to raise_error(Sequel::DatabaseError)
      end
    end

    context 'when provided_as is wrong' do
      let(:params) { attributes_for(:scan, provided_as: 'wrong') }

      it 'should raise Sequel::DatabaseError' do
        expect { subject }.to raise_error(Sequel::DatabaseError)
      end
    end

    context 'when quantity can\'t be cast to integer' do
      let(:params) { attributes_for(:scan, quantity: quantity) }
      let(:quantity) { 'can\'t be cast to integer' }

      it 'should raise Sequel::InvalidValue' do
        expect { subject }.to raise_error(Sequel::InvalidValue)
      end
    end

    context 'when time of creation is of String' do
      context 'when the value is not a time\'s representation' do
        let(:params) { attributes_for(:scan, created_at: value) }
        let(:value) { 'not a time\'s representation' }

        it 'should raise Sequel::InvalidValue' do
          expect { subject }.to raise_error(Sequel::InvalidValue)
        end
      end
    end

    context 'when value of `fs_id` property is nil' do
      let(:params) { attributes_for(:scan, fs_id: value) }
      let(:value) { nil }

      it 'should raise Sequel::InvalidValue' do
        expect { subject }.to raise_error(Sequel::InvalidValue)
      end
    end

    context 'when value of `fs_id` property is of String' do
      context 'when the value is not of UUID format' do
        let(:params) { attributes_for(:scan, fs_id: value) }
        let(:value) { 'not of UUID format' }

        it 'should raise Sequel::DatabaseError' do
          expect { subject }.to raise_error(Sequel::DatabaseError)
        end
      end
    end
  end

  describe 'instance of the model' do
    subject(:instance) { create(:scan) }

    methods = %i[
      correct
      created_at
      direction
      filename
      fs_id
      id
      in_document_id
      last_modified
      mime_type
      provided_as
      quantity
      size
      update
    ]
    it { is_expected.to respond_to(*methods) }
  end

  describe '#correct' do
    subject(:result) { instance.correct }

    let(:instance) { create(:scan) }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is present' do
        it 'should be boolean' do
          expect(subject).to be_truthy.or be_falsey
        end
      end

      context 'when value of the corresponding field is absent' do
        let(:instance) { create(:scan, correct: nil) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#created_at' do
    subject(:result) { instance.created_at }

    let(:instance) { create(:scan) }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is present' do
        it { is_expected.to be_a(Time) }
      end

      context 'when value of the corresponding field is absent' do
        let(:instance) { create(:scan, created_at: nil) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#direction' do
    subject(:result) { instance.direction }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is `input`' do
        let(:instance) { create(:scan, direction: 'input') }

        it { is_expected.to be == 'input' }
      end

      context 'when value of the corresponding field is `output`' do
        let(:instance) { create(:scan, direction: 'output') }

        it { is_expected.to be == 'output' }
      end

      context 'when value of the corresponding field is absent' do
        let(:instance) { create(:scan, direction: nil) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#filename' do
    subject(:result) { instance.filename }

    let(:instance) { create(:scan) }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is present' do
        it { is_expected.to be_a(String) }
      end

      context 'when value of the corresponding field is absent' do
        let(:instance) { create(:scan, filename: nil) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#fs_id' do
    subject(:result) { instance.fs_id }

    let(:instance) { create(:scan) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(String) }

      it 'should be an UUID' do
        hex = '[0-9a-fA-F]'
        expect(subject)
          .to match(/\A#{hex}{8}-#{hex}{4}-#{hex}{4}-#{hex}{4}-#{hex}{12}\z/)
      end
    end
  end

  describe '#id' do
    subject(:result) { instance.id }

    let(:instance) { create(:scan) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_an(Integer) }
    end
  end

  describe '#in_document_id' do
    subject(:result) { instance.in_document_id }

    let(:instance) { create(:scan) }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is present' do
        it { is_expected.to be_a(String) }
      end

      context 'when value of the corresponding field is absent' do
        let(:instance) { create(:scan, in_document_id: nil) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#last_modified' do
    subject(:result) { instance.last_modified }

    let(:instance) { create(:scan) }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is present' do
        it { is_expected.to be_a(String) }
      end

      context 'when value of the corresponding field is absent' do
        let(:instance) { create(:scan, last_modified: nil) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#mime_type' do
    subject(:result) { instance.mime_type }

    let(:instance) { create(:scan) }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is present' do
        it { is_expected.to be_a(String) }
      end

      context 'when value of the corresponding field is absent' do
        let(:instance) { create(:scan, mime_type: nil) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#provided_as' do
    subject(:result) { instance.provided_as }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is `original`' do
        let(:instance) { create(:scan, provided_as: 'original') }

        it { is_expected.to be == 'original' }
      end

      context 'when value of the corresponding field is `copy`' do
        let(:instance) { create(:scan, provided_as: 'copy') }

        it { is_expected.to be == 'copy' }
      end

      context 'when value of the corresponding field is `notarized_copy`' do
        let(:instance) { create(:scan, provided_as: 'notarized_copy') }

        it { is_expected.to be == 'notarized_copy' }
      end

      context 'when value of the corresponding field is `doc_list`' do
        let(:instance) { create(:scan, provided_as: 'doc_list') }

        it { is_expected.to be == 'doc_list' }
      end

      context 'when value of the corresponding field is absent' do
        let(:instance) { create(:scan, provided_as: nil) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#quantity' do
    subject(:result) { instance.quantity }

    let(:instance) { create(:scan) }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is present' do
        it { is_expected.to be_an(Integer) }
      end

      context 'when value of the corresponding field is absent' do
        let(:instance) { create(:scan, quantity: nil) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#size' do
    subject(:result) { instance.size }

    let(:instance) { create(:scan) }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is present' do
        it { is_expected.to be_a(String) }
      end

      context 'when value of the corresponding field is absent' do
        let(:instance) { create(:scan, size: nil) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#update' do
    subject { instance.update(params) }

    let(:instance) { create(:scan) }

    context 'when id is specified' do
      let(:params) { { id: create(:uuid) } }

      it 'should raise Sequel::MassAssignmentRestriction' do
        expect { subject }.to raise_error(Sequel::MassAssignmentRestriction)
      end
    end

    context 'when quantity can\'t be cast to integer' do
      let(:params) { { quantity: quantity } }
      let(:quantity) { 'can\'t be cast to integer' }

      it 'should raise Sequel::InvalidValue' do
        expect { subject }.to raise_error(Sequel::InvalidValue)
      end
    end

    context 'when time of creation is of String' do
      context 'when the value is not a time\'s representation' do
        let(:params) { { created_at: value } }
        let(:value) { 'not a time\'s representation' }

        it 'should raise Sequel::InvalidValue' do
          expect { subject }.to raise_error(Sequel::InvalidValue)
        end
      end
    end

    context 'when `fs_id` property is present in parameters' do
      let(:params) { { fs_id: value } }

      context 'when the value is of String' do
        context 'when the value is an UUID' do
          context 'when the value is not a primary key in files table' do
            let(:value) { create(:uuid) }

            it 'should raise Sequel::ForeignKeyConstraintViolation' do
              expect { subject }
                .to raise_error(Sequel::ForeignKeyConstraintViolation)
            end
          end

          context 'when the value is a primary key in files table' do
            let(:value) { create(:file).id }

            it 'should set `fs_id` attribute to the value' do
              expect { subject }.to change { instance.fs_id }.to(value)
            end
          end
        end

        context 'when the value isn\'t an UUID' do
          let(:value) { 'isn\'t an UUID' }

          it 'should raise Sequel::DatabaseError' do
            expect { subject }.to raise_error(Sequel::DatabaseError)
          end
        end
      end

      context 'when the value is nil' do
        let(:value) { nil }

        it 'should raise Sequel::InvalidValue' do
          expect { subject }.to raise_error(Sequel::InvalidValue)
        end
      end
    end
  end
end
