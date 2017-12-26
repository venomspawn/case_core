# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования функций модуля `CaseCore::Actions::Cases`
#

RSpec.describe CaseCore::Actions::Cases do
  subject { described_class }

  it { is_expected.to respond_to(:index) }

  describe '.index' do
    subject(:result) { described_class.index(params) }

    let(:params) { {} }

    describe 'result' do
      let!(:cases) { create_list(:case, 2) }
      let(:schema) { described_class::Index::RESULT_SCHEMA }

      it { is_expected.to match_json_schema(schema) }
    end

    context 'when argument is not of Hash type' do
      let(:params) { 'not of Hash type' }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end

    context 'when argument is of Hash type but of wrong structure' do
      let(:params) { { filter: :wrong } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end
  end

  it { is_expected.to respond_to(:show) }

  describe '.show' do
    subject(:result) { described_class.show(params) }

    let(:params) { { id: id } }

    describe 'result' do
      subject { result }

      let!(:c4s3) { create(:case) }
      let(:id) { c4s3.id }
      let(:schema) { described_class::Show::RESULT_SCHEMA }

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

  it { is_expected.to respond_to(:show_attributes) }

  describe '.show_attributes' do
    subject(:result) { described_class.show_attributes(params) }

    let(:params) { { id: id } }
    let(:id) { 'id' }

    describe 'result' do
      subject { result }

      let(:c4s3) { create(:case) }
      let(:id) { c4s3.id }
      let!(:attribute1) { create(:case_attribute, case: c4s3) }
      let!(:attribute2) { create(:case_attribute, case: c4s3) }
      let(:name1) { attribute1.name.to_sym }
      let(:name2) { attribute2.name.to_sym }
      let(:value1) { attribute1.value }
      let(:value2) { attribute2.value }
      let(:schema) { described_class::ShowAttributes::RESULT_SCHEMA }

      it { is_expected.to be_a(Hash) }
      it { is_expected.to match_json_schema(schema) }

      describe 'keys' do
        subject { result.keys }

        it { is_expected.to all(be_a(Symbol)) }
      end

      context 'when case record can\'t be found' do
        let(:id) { 'won\'t be found' }

        it { is_expected.to be_empty }
      end

      context 'when `names` parameter is absent`' do
        it 'should extract all attributes' do
          expect(subject).to be == { name1 => value1, name2 => value2 }
        end
      end

      context 'when `names` parameter is nil`' do
        let(:params) { { id: id, names: nil } }

        it 'should extract all attributes' do
          expect(subject).to be == { name1 => value1, name2 => value2 }
        end
      end

      context 'when `names` parameter is empty`' do
        let(:params) { { id: id, names: [] } }

        it { is_expected.to be_empty }
      end

      context 'when `names` parameter specifies attributes`' do
        let(:params) { { id: id, names: [name1] } }

        it 'should extract specified attributes' do
          expect(subject).to be == { name1 => value1 }
        end
      end

      context 'when `names` parameter specifies absent attributes`' do
        let(:params) { { id: id, names: %w(absent) } }

        it { is_expected.to be_empty }
      end
    end

    context 'when argument is not of Hash type' do
      let(:params) { 'not of Hash type' }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end

    context 'when `id` parameter is absent' do
      let(:params) { {} }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end

    context 'when `names` parameter is not `nil` nor a list' do
      let(:params) { { id: 'id', names: 'not `nil` nor a list' } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end

    context 'when `names` parameter contains an element of wrong type' do
      let(:params) { { id: 'id', names: [wrong: :type] } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end

    context 'when `names` parameter contains `id` string' do
      let(:params) { { id: 'id', names: %w(attr id) } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end

    context 'when `names` parameter contains `type` string' do
      let(:params) { { id: 'id', names: %w(attr type) } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end

    context 'when `names` parameter contains `created_at` string' do
      let(:params) { { id: 'id', names: %w(attr created_at) } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end

    context 'when a parameter beside `id` or `name` is present' do
      let(:params) { { id: 'id', names: [], a: :parameter } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end
  end

  it { is_expected.to respond_to(:create) }

  describe '.create' do
    subject { described_class.create(params) }

    let(:params) { { type: :type } }

    it 'should create a record of `CaseCore::Models::Case` model' do
      expect { subject }.to change { CaseCore::Models::Case.count }.by(1)
    end

    context 'when argument is not of Hash type' do
      let(:params) { 'not of Hash type' }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end

    context 'when argument is of Hash type but is of wrong structure' do
      let(:params) { { type: { wrong: :structure } } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end

    context 'when `id` attribute is not specified' do
      it 'should create value of the attribute' do
        expect { subject }.to change { CaseCore::Models::Case.count }.by(1)
      end
    end

    context 'when `id` attribute is specified' do
      let(:params) { { id: id, type: :type } }
      let(:id) { 'id' }

      context 'when a record with the value exists' do
        let!(:case) { create(:case, id: :id, type: :type) }

        it 'should raise Sequel::UniqueConstraintViolation' do
          expect { subject }.to raise_error(Sequel::UniqueConstraintViolation)
        end
      end

      context 'when a record with the value doesn\'t exist' do
        let(:c4s3) { CaseCore::Models::Case.last }

        it 'should use specified value' do
          subject
          expect(c4s3.id).to be == 'id'
        end
      end
    end

    context 'when there are attributes besides `id` and `type`' do
      let(:params) { { type: :type, attr1: :value1, attr2: :value2 } }

      it 'should create records of `CaseCore::Models::CaseAttribute` model' do
        expect { subject }
          .to change { CaseCore::Models::CaseAttribute.count }
          .by(2)
      end
    end

    context 'when there are documents linked to the case' do
      let(:params) { { type: :type, documents: [{ id: :id }, { id: :id2 }] } }

      it 'should create records of `CaseCore::Models::Document` model' do
        expect { subject }.to change { CaseCore::Models::Document.count }.by(2)
      end
    end

    context 'when there is a module to notify about case creation' do
      before do
        CaseCore::Logic::Loader.settings.dir = dir
        allow(logic).to receive(:on_case_creation)
      end

      let(:params) { { type: type } }
      let(:dir) { "#{$root}/spec/fixtures/logic" }
      let(:type) { 'test_case' }
      let(:logic) { CaseCore::Logic::Loader.logic(type) }

      it 'should notify the module' do
        expect(logic)
          .to receive(:on_case_creation)
          .with(CaseCore::Models::Case)
        subject
      end
    end
  end

  it { is_expected.to respond_to(:call) }

  describe '.call' do
    subject { described_class.call(params) }

    let(:params) { { id: id, method: method_name } }
    let(:id) { c4s3.id }
    let(:c4s3) { create(:case, type: type) }
    let(:type) { 'test_case' }
    let(:method_name) { 'a_method' }

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

    context 'when case record can\'t be found' do
      let(:id) { 'won\'t be found' }

      it 'should raise Sequel::NoMatchingRow' do
        expect { subject }.to raise_error(Sequel::NoMatchingRow)
      end
    end

    context 'when logic can\'t be found' do
      let(:type) { 'won\'t be found' }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when method is absent' do
      before { CaseCore::Logic::Loader.settings.dir = dir }

      let(:dir) { "#{$root}/spec/fixtures/logic" }

      it 'should raise NoMethodError' do
        expect { subject }.to raise_error(NoMethodError)
      end
    end

    context 'when an error appears during call' do
      before do
        CaseCore::Logic::Loader.settings.dir = dir
        allow(logic).to receive(method_name).and_raise('')
      end

      let(:dir) { "#{$root}/spec/fixtures/logic" }
      let(:logic) { CaseCore::Logic::Loader.logic(type) }

      it 'should raise the error' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when everything is a\'ight' do
      before do
        CaseCore::Logic::Loader.settings.dir = dir
        allow(logic).to receive(method_name)
      end

      let(:dir) { "#{$root}/spec/fixtures/logic" }
      let(:logic) { CaseCore::Logic::Loader.logic(type) }

      it 'should call the method' do
        expect(logic)
          .to receive(method_name)
          .with(instance_of(CaseCore::Models::Case))
        subject
      end
    end
  end

  it { is_expected.to respond_to(:update) }

  describe '.update' do
    subject { described_class.update(params) }

    let(:params) { { id: id, name => new_value } }
    let(:c4s3) { create(:case) }
    let(:id) { c4s3.id }
    let!(:attr) { create(:case_attribute, *attr_traits) }
    let(:attr_traits) { [case: c4s3, name: name, value: value] }
    let(:name) { 'attr' }
    let(:value) { 'value' }
    let(:new_value) { 'new_value' }

    it 'should update attributes of the case' do
      expect { subject }
        .to change { CaseCore::Actions::Cases.show(id: id)[name.to_sym] }
        .from(value)
        .to(new_value)
    end

    context 'when request record isn\'t found' do
      let(:id) { 'won\'t be found' }

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

    context 'when `type` attribute is present' do
      let(:params) { { id: 'id', type: 'type' } }

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
