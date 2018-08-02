# frozen_string_literal: true

# Тестирование модели атрибутов заявок `CaseCore::Models::RequestAttribute`

RSpec.describe CaseCore::Models::RequestAttribute do
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

    let(:params) { { request_id: request_id, name: :name, value: :value } }
    let(:request_id) { create(:request).id }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(described_class) }
    end

    context 'when request id is not specified' do
      let(:params) { { name: :name, value: :value } }

      it 'should raise Sequel::NotNullConstraintViolation' do
        expect { subject }.to raise_error(Sequel::NotNullConstraintViolation)
      end
    end

    context 'when request id is nil' do
      let(:params) { { request_id: nil, name: :name, value: :value } }

      it 'should raise Sequel::InvalidValue' do
        expect { subject }.to raise_error(Sequel::InvalidValue)
      end
    end

    context 'when name is not specified' do
      let(:params) { { request_id: request_id, value: :value } }

      it 'should raise Sequel::NotNullConstraintViolation' do
        expect { subject }.to raise_error(Sequel::NotNullConstraintViolation)
      end
    end

    context 'when name is nil' do
      let(:params) { { request_id: request_id, name: nil, value: :value } }

      it 'should raise Sequel::InvalidValue' do
        expect { subject }.to raise_error(Sequel::InvalidValue)
      end
    end

    context 'when name is equal to `id`' do
      let(:params) { { request_id: request_id, name: :case_id, value: :v } }

      it 'should raise Sequel::CheckConstraintViolation' do
        expect { subject }.to raise_error(Sequel::CheckConstraintViolation)
      end
    end

    context 'when name is equal to `case_id`' do
      let(:params) { { request_id: request_id, name: :case_id, value: :v } }

      it 'should raise Sequel::CheckConstraintViolation' do
        expect { subject }.to raise_error(Sequel::CheckConstraintViolation)
      end
    end

    context 'when name is equal to `created_at`' do
      let(:params) { { request_id: request_id, name: :created_at, value: :v } }

      it 'should raise Sequel::CheckConstraintViolation' do
        expect { subject }.to raise_error(Sequel::CheckConstraintViolation)
      end
    end

    context 'when request id and name values are used by another record' do
      let(:request_attribute) { create(:request_attribute) }
      let(:request_id) { request_attribute.request_id }
      let(:name) { request_attribute.name }
      let(:params) { { request_id: request_id, name: name, value: :value } }

      it 'should raise Sequel::UniqueConstraintViolation' do
        expect { subject }.to raise_error(Sequel::UniqueConstraintViolation)
      end
    end

    context 'when value is not specified' do
      let(:params) { { request_id: request_id, name: :name } }

      it 'shouldn\'t raise any error' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when value is nil' do
      let(:params) { { request_id: request_id, name: :name, value: nil } }

      it 'shouldn\'t raise any error' do
        expect { subject }.not_to raise_error
      end
    end
  end

  describe 'instance of the model' do
    subject(:instance) { create(:request_attribute) }

    methods = %i[request request_id name value update]
    it { is_expected.to respond_to(*methods) }
  end

  describe '#request' do
    subject(:result) { instance.request }

    let(:instance) { create(:request_attribute) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(CaseCore::Models::Request) }

      it 'should be a record which this record belongs to' do
        expect(result.id) == instance.request_id
      end
    end
  end

  describe '#request_id' do
    subject(:result) { instance.request_id }

    let(:instance) { create(:request_attribute) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(Integer) }
    end
  end

  describe '#name' do
    subject(:result) { instance.name }

    let(:instance) { create(:request_attribute) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(String) }
    end
  end

  describe '#value' do
    subject(:result) { instance.value }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is absent' do
        let(:instance) { create(:request_attribute, value: nil) }

        it { is_expected.to be_nil }
      end

      context 'when value of the corresponding field is present' do
        let(:instance) { create(:request_attribute) }

        it { is_expected.to be_a(String) }
      end
    end
  end

  describe '#update' do
    subject(:result) { instance.update(params) }

    let(:instance) { create(:request_attribute) }

    context 'when value is nil' do
      let(:params) { { value: nil } }

      it 'shouldn\'t raise any error' do
        expect { subject }.not_to raise_error
      end
    end
  end
end
