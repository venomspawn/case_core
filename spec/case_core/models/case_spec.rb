# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестировантия модели заявок `CaseCore::Models::Case`
#

RSpec.describe CaseCore::Models::Case do
  describe 'the model' do
    subject { described_class }

    it { is_expected.to respond_to(:create) }
  end

  describe '.create' do
    subject(:result) { described_class.create(params) }

    let(:params) { { id: create(:string), type: :type, created_at: Time.now } }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(described_class) }
    end

    context 'when case id is not specified' do
      let(:params) { { type: :type, created_at: Time.now } }

      it 'should raise Sequel::NotNullConstraintViolation' do
        expect { subject }.to raise_error(Sequel::NotNullConstraintViolation)
      end
    end

    context 'when case id is nil' do
      let(:params) { { id: nil, type: nil, created_at: Time.now } }

      it 'should raise Sequel::InvalidValue' do
        expect { subject }.to raise_error(Sequel::InvalidValue)
      end
    end

    context 'when case type is not specified' do
      let(:params) { { id: create(:string), created_at: Time.now } }

      it 'should raise Sequel::NotNullConstraintViolation' do
        expect { subject }.to raise_error(Sequel::NotNullConstraintViolation)
      end
    end

    context 'when case type is nil' do
      let(:params) { { id: create(:string), type: nil, created_at: Time.now } }

      it 'should raise Sequel::InvalidValue' do
        expect { subject }.to raise_error(Sequel::InvalidValue)
      end
    end

    context 'when time of creation is not specified' do
      let(:params) { { id: create(:string), type: :type } }

      it 'should raise Sequel::NotNullConstraintViolation' do
        expect { subject }.to raise_error(Sequel::NotNullConstraintViolation)
      end
    end

    context 'when time of creation is nil' do
      let(:params) { { id: create(:string), type: :type, created_at: nil } }

      it 'should raise Sequel::InvalidValue' do
        expect { subject }.to raise_error(Sequel::InvalidValue)
      end
    end
  end

  describe 'instance of the model' do
    subject(:instance) { create(:case) }

    methods = %i(attributes attributes_dataset created_at id type update)
    it { is_expected.to respond_to(*methods) }
  end

  describe '#attributes' do
    subject(:result) { instance.attributes }

    let(:instance) { create(:case) }
    let!(:attributes) { create_list(:case_attribute, 2, case: instance) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_an(Array) }
      it { is_expected.to all(be_a(CaseCore::Models::CaseAttribute)) }
    end
  end

  describe '#attributes_dataset' do
    subject(:result) { instance.attributes_dataset }

    let(:instance) { create(:case) }
    let!(:attributes) { create_list(:case_attribute, 2, case: instance) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(Sequel::Dataset) }

      it 'should be a dataset of CaseCore::Models::CaseAttribute instances' do
        expect(result.model).to be == CaseCore::Models::CaseAttribute
      end

      it 'should be a dataset of records belonging to the instance' do
        expect(result.select_map(:case_id).uniq).to be == [instance.id]
      end
    end
  end

  describe '#created_at' do
    subject(:result) { instance.created_at }

    let(:instance) { create(:case) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(Time) }
    end
  end

  describe '#id' do
    subject(:result) { instance.id }

    let(:instance) { create(:case) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_an(String) }
    end
  end

  describe '#type' do
    subject(:result) { instance.type }

    let(:instance) { create(:case) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(String) }
    end
  end

  describe '#update' do
    subject(:result) { instance.update(params) }

    let(:instance) { create(:case) }

    context 'when case type is nil' do
      let(:params) { { type: nil } }

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
  end
end
