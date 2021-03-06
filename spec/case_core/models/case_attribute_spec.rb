# frozen_string_literal: true

# Тестирование модели атрибутов заявок `CaseCore::Models::CaseAttribute`

RSpec.describe CaseCore::Models::CaseAttribute do
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

    let(:params) { { case_id: case_id, name: :name, value: :value } }
    let(:case_id) { create(:case).id }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(described_class) }
    end

    context 'when case id is not specified' do
      let(:params) { { name: :name, value: :value } }

      it 'should raise Sequel::NotNullConstraintViolation' do
        expect { subject }.to raise_error(Sequel::NotNullConstraintViolation)
      end
    end

    context 'when case id is nil' do
      let(:params) { { case_id: nil, name: :name, value: :value } }

      it 'should raise Sequel::InvalidValue' do
        expect { subject }.to raise_error(Sequel::InvalidValue)
      end
    end

    context 'when name is not specified' do
      let(:params) { { case_id: case_id, value: :value } }

      it 'should raise Sequel::NotNullConstraintViolation' do
        expect { subject }.to raise_error(Sequel::NotNullConstraintViolation)
      end
    end

    context 'when name is nil' do
      let(:params) { { case_id: case_id, name: nil, value: :value } }

      it 'should raise Sequel::InvalidValue' do
        expect { subject }.to raise_error(Sequel::InvalidValue)
      end
    end

    context 'when name is equal to `id`' do
      let(:params) { { case_id: case_id, name: :id, value: :value } }

      it 'should raise Sequel::CheckConstraintViolation' do
        expect { subject }.to raise_error(Sequel::CheckConstraintViolation)
      end
    end

    context 'when name is equal to `type`' do
      let(:params) { { case_id: case_id, name: :type, value: :value } }

      it 'should raise Sequel::CheckConstraintViolation' do
        expect { subject }.to raise_error(Sequel::CheckConstraintViolation)
      end
    end

    context 'when name is equal to `created_at`' do
      let(:params) { { case_id: case_id, name: :created_at, value: :value } }

      it 'should raise Sequel::CheckConstraintViolation' do
        expect { subject }.to raise_error(Sequel::CheckConstraintViolation)
      end
    end

    context 'when name is equal to `documents`' do
      let(:params) { { case_id: case_id, name: :documents, value: :value } }

      it 'should raise Sequel::CheckConstraintViolation' do
        expect { subject }.to raise_error(Sequel::CheckConstraintViolation)
      end
    end

    context 'when case id and name values are used by another record' do
      let(:case_attribute) { create(:case_attribute) }
      let(:case_id) { case_attribute.case_id }
      let(:name) { case_attribute.name }
      let(:params) { { case_id: case_id, name: name, value: :value } }

      it 'should raise Sequel::UniqueConstraintViolation' do
        expect { subject }.to raise_error(Sequel::UniqueConstraintViolation)
      end
    end

    context 'when value is not specified' do
      let(:params) { { case_id: case_id, name: :name } }

      it 'shouldn\'t raise any error' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when value is nil' do
      let(:params) { { case_id: case_id, name: :name, value: nil } }

      it 'shouldn\'t raise any error' do
        expect { subject }.not_to raise_error
      end
    end
  end

  describe 'instance of the model' do
    subject(:instance) { create(:case_attribute) }

    it { is_expected.to respond_to(:case, :case_id, :name, :value, :update) }
  end

  describe '#case' do
    subject(:result) { instance.case }

    let(:instance) { create(:case_attribute) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(CaseCore::Models::Case) }

      it 'should be a record which this record belongs to' do
        expect(result.id) == instance.case_id
      end
    end
  end

  describe '#case_id' do
    subject(:result) { instance.case_id }

    let(:instance) { create(:case_attribute) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(String) }
    end
  end

  describe '#name' do
    subject(:result) { instance.name }

    let(:instance) { create(:case_attribute) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(String) }
    end
  end

  describe '#value' do
    subject(:result) { instance.value }

    describe 'result' do
      subject { result }

      context 'when value is absent' do
        let(:instance) { create(:case_attribute, value: nil) }

        it { is_expected.to be_nil }
      end

      context 'when value is present' do
        let(:instance) { create(:case_attribute) }

        it { is_expected.to be_a(String) }
      end
    end
  end

  describe '#update' do
    subject(:result) { instance.update(params) }

    let(:instance) { create(:case_attribute) }

    context 'when value is nil' do
      let(:params) { { value: nil } }

      it 'shouldn\'t raise any error' do
        expect { subject }.not_to raise_error
      end
    end
  end
end
