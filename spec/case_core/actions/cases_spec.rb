# frozen_string_literal: true

# Файл тестирования функций модуля `CaseCore::Actions::Cases`

RSpec.describe CaseCore::Actions::Cases do
  subject { described_class }

  it { is_expected.to respond_to(:index) }

  describe '.index' do
    include described_class::Index::SpecHelper

    subject(:result) { described_class.index(params) }

    describe 'result' do
      subject { result }

      let(:schema) { described_class::Index::RESULT_SCHEMA }

      it { is_expected.to match_json_schema(schema) }

      describe 'elements' do
        subject(:ids) { result.map { |hash| hash[:id] } }

        it 'should contain info of cases' do
          expect(ids).to match_array %w[1 2 3 4 5]
        end

        context 'when `filter` parameter is specified' do
          let(:params) { { filter: filter } }

          context 'when the parameter value is a map' do
            context 'when a value of the map is a map' do
              context 'when there is `exclude` key' do
                let(:filter) { { rguid: { exclude: '101' } } }

                it 'should be all infos but selected by `exclude` value' do
                  expect(ids).to match_array %w[2 3 4 5]
                end
              end

              context 'when there is `like` key' do
                let(:filter) { { rguid: { like: '%000%' } } }

                it 'should be all infos with likely value' do
                  expect(ids).to match_array %w[3 4 5]
                end
              end

              context 'when there is `min` key' do
                let(:filter) { { state: { min: 'error' } } }

                it 'should be all infos with values no less than value' do
                  expect(ids).to match_array %w[1 2 4 5]
                end
              end

              context 'when there is `max` key' do
                let(:filter) { { state: { max: 'error' } } }

                it 'should be all infos with values no more than value' do
                  expect(ids).to match_array %w[2 3]
                end
              end

              context 'when there is more than one supported key specified' do
                let(:filter) { { state: { min: 'error', exclude: 'ok' } } }

                it 'should be all infos selected by all filters together' do
                  expect(ids).to match_array %w[2 4]
                end
              end

              context 'when there is a key but it\'s unsupported' do
                let(:filter) { { state: { unsupported: :key } } }

                it 'should raise JSON::Schema::ValidationError' do
                  expect { subject }
                    .to raise_error { JSON::Schema::ValidationError }
                end
              end

              context 'when there is no any key' do
                let(:filter) { { state: {} } }

                it 'should raise JSON::Schema::ValidationError' do
                  expect { subject }
                    .to raise_error { JSON::Schema::ValidationError }
                end
              end
            end

            context 'when a value is a list' do
              let(:filter) { { state: %w[ok error] } }

              it 'should be all infos with values from the list' do
                expect(ids).to match_array %w[1 2 5]
              end
            end

            context 'when a value is not a list nor a map' do
              let(:filter) { { state: 'ok' } }

              it 'should be all infos with the value' do
                expect(ids).to match_array %w[1 5]
              end
            end
          end

          context 'when the parameter value is a list' do
            context 'when the list is empty' do
              let(:filter) { [] }

              it 'should be all infos' do
                expect(ids).to match_array %w[1 2 3 4 5]
              end
            end

            context 'when the list contains filters' do
              let(:filter) { [{ state: 'ok' }, { op_id: '2abc' }] }

              it 'should be selected by at least one filter' do
                expect(ids).to match_array %w[1 2 5]
              end
            end
          end
        end

        context 'when `limit` parameter is specified' do
          let(:params) { { limit: limit } }
          let(:limit) { 2 }

          it 'should be no more in quantity than the limit' do
            expect(ids.count).to be <= limit
          end

          context 'when `order` parameter isn\'t specified' do
            it 'should be ordered by `id` field' do
              expect(ids).to be == %w[1 2]
            end
          end
        end

        context 'when `offset` parameter is specified' do
          let(:params) { { offset: offset } }
          let(:offset) { 2 }

          it 'should be shifted by offset' do
            expect(ids).to match_array %w[3 4 5]
          end

          context 'when `order` parameter isn\'t specified' do
            it 'should be ordered by `id` field' do
              expect(ids).to be == %w[3 4 5]
            end
          end
        end

        context 'when `order` parameter is specified' do
          let(:params) { { order: { type: :asc, id: :desc } } }

          it 'should be ordered by specified fields and directions' do
            expect(ids).to be == %w[5 4 3 2 1]
          end
        end

        context 'when `fields` parameter is specified' do
          let(:params) { { fields: %w[id state] } }

          it 'should contain only specified fields' do
            expect(result.map(&:keys).flatten.uniq).to match_array %i[id state]
          end

          context 'when there is no `id` field in the value' do
            let(:params) { { fields: %w[state] } }

            it 'should still contain `id` field' do
              expect(result.map(&:keys).flatten.uniq).to include :id
            end
          end
        end

        context 'when all supported parameters are specified' do
          let(:params) { { filter: filter, **paging, order: order } }
          let(:filter) { [{ state: 'ok' }, { rguid: { like: '%000%' } }] }
          let(:paging) { { limit: limit, offset: offset } }
          let(:limit) { 2 }
          let(:offset) { 1 }
          let(:order) { { id: :desc } }

          it 'should be properly extracted infos' do
            expect(ids).to be == %w[4 3]
          end
        end
      end
    end

    let(:params) { {} }
    let!(:cases) { create_cases }

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
      let!(:case_attribute) { create(:case_attribute, *args) }
      let(:args) { [case_id: c4s3.id, name: 'attr', value: 'value'] }
      let(:id) { c4s3.id }
      let(:schema) { described_class::Show::RESULT_SCHEMA }

      it { is_expected.to match_json_schema(schema) }

      context 'when names parameter is absent' do
        let(:params) { { id: id } }

        it 'should contain all attributes' do
          expect(result.keys).to match_array %i[id type created_at attr]
        end
      end

      context 'when names parameter is nil' do
        let(:params) { { id: id, names: nil } }

        it 'should contain all attributes' do
          expect(result.keys).to match_array %i[id type created_at attr]
        end
      end

      context 'when names parameter is a list' do
        context 'when the list is empty' do
          let(:params) { { id: id, names: [] } }

          it 'should contain only case fields' do
            expect(result.keys).to match_array %i[id type created_at]
          end
        end

        context 'when the list contains case attribute name' do
          let(:params) { { id: id, names: %w[attr] } }

          it 'should contain the attribute' do
            expect(result.keys).to match_array %i[id type created_at attr]
          end
        end

        context 'when the list contains unknown name' do
          let(:params) { { id: id, names: %w[unknown] } }

          it 'should be a\'ight' do
            expect(result.keys).to match_array %i[id type created_at]
          end
        end
      end
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
        let(:params) { { id: id, names: %w[absent] } }

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
      let(:params) { { id: 'id', names: %w[attr id] } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end

    context 'when `names` parameter contains `type` string' do
      let(:params) { { id: 'id', names: %w[attr type] } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end

    context 'when `names` parameter contains `created_at` string' do
      let(:params) { { id: 'id', names: %w[attr created_at] } }

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
    before { CaseCore::Logic::Loader.settings.dir = dir }

    subject { described_class.create(params) }

    let(:dir) { "#{$root}/spec/fixtures/logic" }
    let(:params) { { type: type, **attrs, **documents } }
    let(:attrs) { {} }
    let(:documents) { {} }

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

    context 'when there is no module of business logic for the case' do
      let(:type) { 'no module for the case' }
      let(:attrs) { { attr1: :value1, attr2: :value2 } }
      let(:documents) { { documents: [{ id: 'id' }, { id: 'id2' }] } }

      it 'should raise `RuntimeError`' do
        expect { subject }.to raise_error(RuntimeError)
      end

      it 'shouldn\'t create case records' do
        expect { subject }
          .to raise_error(RuntimeError)
          .and change { CaseCore::Models::Case.count }.by(0)
      end

      it 'shouldn\'t create records of case attributes' do
        expect { subject }
          .to raise_error(RuntimeError)
          .and change { CaseCore::Models::CaseAttribute.count }.by(0)
      end

      it 'shouldn\'t create records of documents' do
        expect { subject }
          .to raise_error(RuntimeError)
          .and change { CaseCore::Models::Document.count }.by(0)
      end
    end

    context 'when there is a module of business logic for the case' do
      let(:type) { 'test_case' }

      context 'when the module doesn\'t provide `on_case_creation` function' do
        let(:attrs) { { attr1: :value1, attr2: :value2 } }
        let(:documents) { { documents: [{ id: 'id' }, { id: 'id2' }] } }

        it 'should raise `RuntimeError`' do
          expect { subject }.to raise_error(RuntimeError)
        end

        it 'shouldn\'t create case records' do
          expect { subject }
            .to raise_error(RuntimeError)
            .and change { CaseCore::Models::Case.count }.by(0)
        end

        it 'shouldn\'t create records of case attributes' do
          expect { subject }
            .to raise_error(RuntimeError)
            .and change { CaseCore::Models::CaseAttribute.count }.by(0)
        end

        it 'shouldn\'t create records of documents' do
          expect { subject }
            .to raise_error(RuntimeError)
            .and change { CaseCore::Models::Document.count }.by(0)
        end
      end

      context 'when the module provides `on_case_creation` function' do
        before { allow(logic).to receive(:on_case_creation) }

        let(:logic) { CaseCore::Logic::Loader.logic(type) }

        it 'should call the function' do
          expect(logic)
            .to receive(:on_case_creation)
            .with(CaseCore::Models::Case)
          subject
        end

        context 'when the function raises `ArgumentError`' do
          before do
            allow(logic).to receive(:on_case_creation).and_raise(error)
          end

          let(:error) { ArgumentError.new }
          let(:attrs) { { attr1: :value1, attr2: :value2 } }
          let(:documents) { { documents: [{ id: 'id' }, { id: 'id2' }] } }

          it 'should raise the error' do
            expect { subject }.to raise_error(error)
          end

          it 'shouldn\'t create case records' do
            expect { subject }
              .to raise_error(error)
              .and change { CaseCore::Models::Case.count }.by(0)
          end

          it 'shouldn\'t create records of case attributes' do
            expect { subject }
              .to raise_error(error)
              .and change { CaseCore::Models::CaseAttribute.count }.by(0)
          end

          it 'shouldn\'t create records of documents' do
            expect { subject }
              .to raise_error(error)
              .and change { CaseCore::Models::Document.count }.by(0)
          end
        end

        context 'when the function raises other errors' do
          before do
            allow(logic).to receive(:on_case_creation).and_raise(NameError)
          end

          it 'should create a record of `CaseCore::Models::Case` model' do
            expect { subject }.to change { CaseCore::Models::Case.count }.by(1)
          end

          context 'when `id` attribute is not specified' do
            it 'should create value of the attribute' do
              expect { subject }
                .to change { CaseCore::Models::Case.count }
                .by(1)
            end
          end

          context 'when `id` attribute is specified' do
            let(:params) { { id: id, type: type } }
            let(:id) { 'id' }

            context 'when a record with the value exists' do
              let!(:case) { create(:case, id: :id, type: type) }

              it 'should raise Sequel::UniqueConstraintViolation' do
                expect { subject }
                  .to raise_error(Sequel::UniqueConstraintViolation)
              end
            end

            context 'when a record with the value doesn\'t exist' do
              let(:c4s3) { CaseCore::Models::Case.last }

              it 'should use specified value' do
                subject
                expect(c4s3.id).to be == id
              end
            end
          end

          context 'when there are attributes besides `id` and `type`' do
            let(:attrs) { { attr1: :value1, attr2: :value2 } }

            it 'should create records of case attributes' do
              expect { subject }
                .to change { CaseCore::Models::CaseAttribute.count }
                .by(2)
            end
          end

          context 'when there are documents linked to the case' do
            let(:documents) { { documents: [{ id: 'id' }, { id: 'id2' }] } }

            it 'should create records of documents' do
              expect { subject }
                .to change { CaseCore::Models::Document.count }
                .by(2)
            end
          end
        end

        context 'when the function doesn\'t raise an error' do
          it 'should create a record of `CaseCore::Models::Case` model' do
            expect { subject }.to change { CaseCore::Models::Case.count }.by(1)
          end

          context 'when `id` attribute is not specified' do
            it 'should create value of the attribute' do
              expect { subject }
                .to change { CaseCore::Models::Case.count }
                .by(1)
            end
          end

          context 'when `id` attribute is specified' do
            let(:params) { { id: id, type: type } }
            let(:id) { 'id' }

            context 'when a record with the value exists' do
              let!(:case) { create(:case, id: :id, type: type) }

              it 'should raise Sequel::UniqueConstraintViolation' do
                expect { subject }
                  .to raise_error(Sequel::UniqueConstraintViolation)
              end
            end

            context 'when a record with the value doesn\'t exist' do
              let(:c4s3) { CaseCore::Models::Case.last }

              it 'should use specified value' do
                subject
                expect(c4s3.id).to be == id
              end
            end
          end

          context 'when there are attributes besides `id` and `type`' do
            let(:attrs) { { attr1: :value1, attr2: :value2 } }

            it 'should create records of case attributes' do
              expect { subject }
                .to change { CaseCore::Models::CaseAttribute.count }
                .by(2)
            end
          end

          context 'when there are documents linked to the case' do
            let(:documents) { { documents: [{ id: 'id' }, { id: 'id2' }] } }

            it 'should create records of documents' do
              expect { subject }
                .to change { CaseCore::Models::Document.count }
                .by(2)
            end
          end
        end
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

  it { is_expected.to respond_to(:count) }

  describe '.count' do
    subject(:result) { described_class.count(params) }

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

    describe 'result' do
      include described_class::Count::SpecHelper

      subject { result }

      let(:params) { {} }
      let!(:cases) { create_cases }
      let(:schema) { described_class::Count::RESULT_SCHEMA }

      it { is_expected.to match_json_schema(schema) }

      describe 'value of `count` attribute' do
        subject(:count) { result[:count] }

        it 'should be count of filtered cases' do
          expect(subject).to be == 5
        end

        context 'when `filter` parameter is specified' do
          let(:params) { { filter: filter } }

          context 'when the parameter value is a map' do
            context 'when a value of the map is a map' do
              context 'when there is `exclude` key' do
                let(:filter) { { rguid: { exclude: '101' } } }

                it 'should be count of cases filtered by `exclude` value' do
                  expect(subject).to be == 4
                end
              end

              context 'when there is `like` key' do
                let(:filter) { { rguid: { like: '%000%' } } }

                it 'should be count of cases filtered by likely value' do
                  expect(subject).to be == 3
                end
              end

              context 'when there is `min` key' do
                let(:filter) { { state: { min: 'error' } } }

                it 'should be count of cases with values no less than value' do
                  expect(subject).to be == 4
                end
              end

              context 'when there is `max` key' do
                let(:filter) { { state: { max: 'error' } } }

                it 'should be count of cases with values no more than value' do
                  expect(subject).to be == 2
                end
              end

              context 'when there is more than one supported key specified' do
                let(:filter) { { state: { min: 'error', exclude: 'ok' } } }

                it 'should be count of cases filtered by filters together' do
                  expect(subject).to be == 2
                end
              end

              context 'when there is a key but it\'s unsupported' do
                let(:filter) { { state: { unsupported: :key } } }

                it 'should raise JSON::Schema::ValidationError' do
                  expect { subject }
                    .to raise_error { JSON::Schema::ValidationError }
                end
              end

              context 'when there is no any key' do
                let(:filter) { { state: {} } }

                it 'should raise JSON::Schema::ValidationError' do
                  expect { subject }
                    .to raise_error { JSON::Schema::ValidationError }
                end
              end
            end

            context 'when a value is a list' do
              let(:filter) { { state: %w[ok error] } }

              it 'should be count of cases with values from the list' do
                expect(subject).to be == 3
              end
            end

            context 'when a value is not a list nor a map' do
              let(:filter) { { state: 'ok' } }

              it 'should be count of cases with the value' do
                expect(subject).to be == 2
              end
            end
          end

          context 'when the parameter value is a list' do
            context 'when the list is empty' do
              let(:filter) { [] }

              it 'should be count of all cases' do
                expect(subject).to be == 5
              end
            end

            context 'when the list contains filters' do
              let(:filter) { [{ state: 'ok' }, { op_id: '2abc' }] }

              it 'should be count of cases selected by at least one filter' do
                expect(subject).to be == 3
              end
            end
          end
        end

        context 'when `limit` parameter is specified' do
          let(:params) { { limit: limit } }
          let(:limit) { 2 }

          it 'should be count of cases no more than the limit' do
            expect(subject).to be <= limit
          end
        end

        context 'when `offset` parameter is specified' do
          let(:params) { { offset: offset } }
          let(:offset) { 2 }

          it 'should be count of cases shifted by offset' do
            expect(subject).to be == 3
          end
        end

        context 'when all supported parameters are specified' do
          let(:params) { { filter: filter, limit: 2, offset: 1 } }
          let(:filter) { [{ state: 'ok' }, { rguid: { like: '%000%' } }] }

          it 'should be count of filtered cases' do
            expect(subject).to be == 2
          end
        end
      end
    end
  end
end
