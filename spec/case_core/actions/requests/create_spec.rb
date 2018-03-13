# frozen_string_literal: true

# Файл тестирования класса действия создания записи межведомственного запроса

RSpec.describe CaseCore::Actions::Requests::Create do
  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:new) }
  end

  describe '.new' do
    subject(:result) { described_class.new(params) }

    let(:params) { { case_id: 'case_id' } }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(described_class) }
    end

    context 'when argument is not of Hash type' do
      let(:params) { 'not of Hash type' }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end

    context 'when `case_id` attribute is absent' do
      let(:params) { {} }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end
  end

  describe 'instance' do
    subject { described_class.new(params) }

    let(:params) { { case_id: 'case_id' } }

    it { is_expected.to respond_to(:create) }
  end

  describe '#create' do
    subject(:result) { instance.create }

    let(:instance) { described_class.new(params) }
    let(:params) { { case_id: case_id } }
    let(:case_id) { c4s3.id }
    let(:c4s3) { create(:case) }

    it 'should create a record of `CaseCore::Models::Request` model' do
      expect { subject }.to change { CaseCore::Models::Request.count }.by(1)
    end

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(CaseCore::Models::Request) }
    end

    context 'when `id` attribute is specified' do
      let(:params) { { id: id, case_id: case_id } }
      let(:id) { -1 }

      it 'should be ignored' do
        expect(result.id).not_to be == id
      end
    end

    context 'when `created_at` attribute is specified' do
      let(:params) { { case_id: case_id, created_at: created_at } }
      let(:created_at) { Time.now - 60 }

      it 'should be ignored' do
        expect(result.created_at).not_to be == created_at
      end
    end

    context 'when `case_id` is wrong' do
      let(:case_id) { 'won\'t be found' }

      it 'should raise Sequel::ForeignKeyConstraintViolation' do
        expect { subject }
          .to raise_error(Sequel::ForeignKeyConstraintViolation)
      end
    end

    context 'when there are additional attributes' do
      let(:params) { { case_id: case_id, attr1: 'value1', attr2: 'value2' } }

      it 'should create records of\'em' do
        expect { subject }
          .to change { CaseCore::Models::RequestAttribute.count }
          .by(2)
      end
    end
  end
end
