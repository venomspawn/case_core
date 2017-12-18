# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования функций модуля `CaseCore::Actions::Requests`
#

RSpec.describe CaseCore::Actions::Requests do
  subject { described_class }

  it { is_expected.to respond_to(:create) }

  describe '.create' do
    subject(:result) { described_class.create(params) }

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

  it { is_expected.to respond_to(:index) }

  describe '.index' do
    subject(:result) { described_class.index(params) }

    let(:params) { { id: id } }

    describe 'result' do
      subject { result }

      let!(:c4s3) { create(:case) }
      let!(:requests) { create_list(:request, 2, case: c4s3) }
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

  it { is_expected.to respond_to(:show) }

  describe '.show' do
    subject(:result) { described_class.show(params) }

    let(:params) { { id: id } }

    describe 'result' do
      subject { result }

      let(:c4s3) { create(:case) }
      let(:request) { create(:request, case: c4s3) }
      let!(:request_attr) { create(:request_attribute, *traits) }
      let(:traits) { [request: request, name: 'name', value: 'value'] }
      let(:id) { request.id }
      let(:schema) { described_class::Show::RESULT_SCHEMA }

      it { is_expected.to match_json_schema(schema) }
    end

    context 'when request record can\'t be found by provided id' do
      let(:id) { 100_500 }

      it 'should raise Sequel::NoMatchingRow' do
        expect { subject }.to raise_error(Sequel::NoMatchingRow)
      end
    end

    context 'when argument is not of Hash type' do
      let(:params) { 'not of Hash type' }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end

    context 'when `id` attribute is absent' do
      let(:params) { { doesnt: :have_id_attribute } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end

    context 'when an attribute is present beside `id` attribute' do
      let(:params) { { id: 1, an: :attribute } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end
  end

  it { is_expected.to respond_to(:update) }

  describe '.update' do
    subject { described_class.update(params) }

    let(:params) { { id: id, name => new_value } }
    let(:request) { create(:request, case: c4s3) }
    let(:c4s3) { create(:case) }
    let(:id) { request.id }
    let!(:attr) { create(:request_attribute, *attr_traits) }
    let(:attr_traits) { [request: request, name: name, value: value] }
    let(:name) { 'attr' }
    let(:value) { 'value' }
    let(:new_value) { 'new_value' }

    it 'should update attributes of the request' do
      expect { subject }
        .to change { CaseCore::Actions::Requests.show(id: id)[name] }
        .from(value)
        .to(new_value)
    end

    context 'when request record isn\'t found' do
      let(:id) { 100_500 }

      it 'should raise Sequel::ForeignKeyConstraintViolation' do
        expect { subject }
          .to raise_error(Sequel::ForeignKeyConstraintViolation)
      end
    end

    context 'when argument is not of Hash type' do
      let(:params) { 'not of Hash type' }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end

    context 'when `id` attribute is absent' do
      let(:params) { { attr: 'attr' } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end

    context 'when only `id` attribute is present' do
      let(:params) { { id: 'id' } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end

    context 'when `id` attribute is of wrong type' do
      let(:params) { { id: 'of wrong type', attr: 'attr' } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end

    context 'when `case_id` attribute is present' do
      let(:params) { { id: 'id', case_id: 'case_id' } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end

    context 'when `created_at` attribute is present' do
      let(:params) { { id: 'id', created_at: 'created_at' } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end
  end
end
