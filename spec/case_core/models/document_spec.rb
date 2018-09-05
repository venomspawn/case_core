# frozen_string_literal: true

# Тестирование модели документа `CaseCore::Models::Document`

RSpec.describe CaseCore::Models::Document do
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

    context 'when both case and case id are not specified' do
      let(:params) { { id: id } }

      it 'should raise Sequel::NotNullConstraintViolation' do
        expect { subject }.to raise_error(Sequel::NotNullConstraintViolation)
      end
    end

    context 'when case is nil and case id is not specified' do
      let(:params) { { id: id, case: nil } }

      it 'should raise Sequel::InvalidValue' do
        expect { subject }.to raise_error(Sequel::InvalidValue)
      end
    end

    context 'when case_id is nil and case is not specified' do
      let(:params) { { id: id, case_id: nil } }

      it 'should raise Sequel::InvalidValue' do
        expect { subject }.to raise_error(Sequel::InvalidValue)
      end
    end

    context 'when scan id is not nil and is not a primary key of scans' do
      let(:params) { { id: id, case: c4s3, scan_id: 100_500 } }

      it 'should raise Sequel::ForeignKeyConstraintViolation' do
        expect { subject }
          .to raise_error(Sequel::ForeignKeyConstraintViolation)
      end
    end
  end

  describe 'instance of the model' do
    subject(:instance) { create(:document) }

    methods = %i[case case_id id scan_id title update]
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

  describe '#id' do
    subject(:result) { instance.id }

    let(:instance) { create(:document) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(String) }
    end
  end

  describe '#scan_id' do
    subject(:result) { instance.scan_id }

    let(:instance) { create(:document) }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is present' do
        let(:instance) { create(:document, :with_scan) }

        it { is_expected.to be_an(Integer) }

        it 'should be a primary key in scans table' do
          expect(CaseCore::Models::Scan[result]).not_to be_nil
        end
      end

      context 'when value of the corresponding field is absent' do
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

    context 'when scan id is not nil and is not a primary key of scans' do
      let(:params) { { scan_id: 100_500 } }

      it 'should raise Sequel::ForeignKeyConstraintViolation' do
        expect { subject }
          .to raise_error(Sequel::ForeignKeyConstraintViolation)
      end
    end
  end
end
