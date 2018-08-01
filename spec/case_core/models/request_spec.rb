# frozen_string_literal: true

# Тестирование модели межведомственного запроса
# `CaseCore::Models::Request`

RSpec.describe CaseCore::Models::Request do
  describe 'the model' do
    subject { described_class }

    it { is_expected.to respond_to(:new, :create) }
  end

  describe '.new' do
    subject(:result) { described_class.new(params) }

    describe 'result' do
      subject { result }

      let(:params) { attributes_for(:request) }

      it { is_expected.to be_an_instance_of(described_class) }
    end
  end

  describe '.create' do
    subject(:result) { described_class.create(params) }

    let(:params) { { case_id: c4s3.id, created_at: Time.now } }
    let(:c4s3) { create(:case) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(described_class) }
    end

    context 'when case id is not specified' do
      let(:params) { { created_at: Time.now } }

      it 'should raise Sequel::NotNullConstraintViolation' do
        expect { subject }.to raise_error(Sequel::NotNullConstraintViolation)
      end
    end

    context 'when case id is nil' do
      let(:params) { { case_id: nil, created_at: Time.now } }

      it 'should raise Sequel::InvalidValue' do
        expect { subject }.to raise_error(Sequel::InvalidValue)
      end
    end

    context 'when time of creation is not specified' do
      let(:params) { { case_id: c4s3.id } }

      it 'should raise Sequel::NotNullConstraintViolation' do
        expect { subject }.to raise_error(Sequel::NotNullConstraintViolation)
      end
    end

    context 'when time of creation is nil' do
      let(:params) { { case_id: c4s3.id, created_at: nil } }

      it 'should raise Sequel::InvalidValue' do
        expect { subject }.to raise_error(Sequel::InvalidValue)
      end
    end

    context 'when time of creation is of String' do
      context 'when the value is not a time\'s representation' do
        let(:params) { { case_id: c4s3.id, created_at: value } }
        let(:value) { 'not a time\'s representation' }

        it 'should raise Sequel::InvalidValue' do
          expect { subject }.to raise_error(Sequel::InvalidValue)
        end
      end
    end
  end

  describe 'instance of the model' do
    subject(:instance) { create(:request) }

    methods =
      %i[attributes attributes_dataset case case_id created_at id update]
    it { is_expected.to respond_to(*methods) }
  end

  describe '#attributes' do
    subject(:result) { instance.attributes }

    let(:instance) { create(:request) }
    let!(:attributes) { create_list(:request_attribute, 2, request: instance) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_an(Array) }
      it { is_expected.to all(be_a(CaseCore::Models::RequestAttribute)) }

      it 'should be a list of attributes belonging to the case' do
        expect(subject.map(&:request_id).uniq).to be == [instance.id]
      end
    end
  end

  describe '#attributes_dataset' do
    subject(:result) { instance.attributes_dataset }

    let(:instance) { create(:request) }
    let!(:attributes) { create_list(:request_attribute, 2, request: instance) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(Sequel::Dataset) }

      it 'should be a dataset of proper instances' do
        expect(result.model).to be == CaseCore::Models::RequestAttribute
      end

      it 'should be a dataset of records belonging to the instance' do
        expect(result.select_map(:request_id).uniq).to be == [instance.id]
      end
    end
  end

  describe '#case' do
    subject(:result) { instance.case }

    let(:instance) { create(:request) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(CaseCore::Models::Case) }

      it 'should be a record this record belongs to' do
        expect(result.id) == instance.case_id
      end
    end
  end

  describe '#case_id' do
    subject(:result) { instance.case_id }

    let(:instance) { create(:request) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(String) }
    end
  end

  describe '#created_at' do
    subject(:result) { instance.created_at }

    let(:instance) { create(:request) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(Time) }
    end
  end

  describe '#id' do
    subject(:result) { instance.id }

    let(:instance) { create(:request) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_an(Integer) }
    end
  end

  describe '#update' do
    subject(:result) { instance.update(params) }

    let(:instance) { create(:request) }

    context 'when case id is nil' do
      let(:params) { { case_id: nil } }

      it 'should raise Sequel::InvalidValue' do
        expect { subject }.to raise_error(Sequel::InvalidValue)
      end
    end

    context 'when time of creation is nil' do
      let(:params) { { created_at: nil } }

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
  end
end
