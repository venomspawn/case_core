# frozen_string_literal: true

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования функций модуля `CaseCore::Actions::Requests`
#

RSpec.describe CaseCore::Actions::Requests do
  subject { described_class }

  it { is_expected.to respond_to(:count) }

  describe '.count' do
    include described_class::Count::SpecHelper

    subject(:result) { described_class.count(params) }

    let(:params) { { id: id } }

    describe 'result' do
      subject { result }

      let!(:c4s3) { create(:case) }
      let(:id) { c4s3.id }
      let!(:requests) { create_requests(c4s3) }
      let(:schema) { described_class::Count::RESULT_SCHEMA }

      it { is_expected.to match_json_schema(schema) }

      describe 'value of `count` attribute' do
        subject(:count) { result[:count] }

        it 'should be count of filtered requests of the case' do
          expect(subject).to be == 5
        end

        context 'when `filter` parameter is specified' do
          let(:params) { { id: id, filter: filter } }

          context 'when the parameter value is a map' do
            context 'when a value of the map is a map' do
              context 'when there is `exclude` key' do
                let(:filter) { { rguid: { exclude: '101' } } }

                it 'should be count of requests filtered by `exclude` value' do
                  expect(subject).to be == 4
                end
              end

              context 'when there is `like` key' do
                let(:filter) { { rguid: { like: '%000%' } } }

                it 'should be count of requests filtered by likely value' do
                  expect(subject).to be == 3
                end
              end

              context 'when there is `min` key' do
                let(:filter) { { state: { min: 'error' } } }

                it 'should be count of requests with no less values' do
                  expect(subject).to be == 4
                end
              end

              context 'when there is `max` key' do
                let(:filter) { { state: { max: 'error' } } }

                it 'should be count of requests with no more values' do
                  expect(subject).to be == 2
                end
              end

              context 'when there is more than one supported key specified' do
                let(:filter) { { state: { min: 'error', exclude: 'ok' } } }

                it 'should be count of requests filtered by the filters' do
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

              it 'should be count of requests with values from the list' do
                expect(subject).to be == 3
              end
            end

            context 'when a value is not a list nor a map' do
              let(:filter) { { state: 'ok' } }

              it 'should be count of requests with the value' do
                expect(subject).to be == 2
              end
            end
          end

          context 'when the parameter value is a list' do
            context 'when the list is empty' do
              let(:filter) { [] }

              it 'should be count of all requests' do
                expect(subject).to be == 5
              end
            end

            context 'when the list contains filters' do
              let(:filter) { [{ state: 'ok' }, { op_id: '2abc' }] }

              it 'should be count of requests selected by at least one' do
                expect(subject).to be == 3
              end
            end
          end
        end

        context 'when `limit` parameter is specified' do
          let(:params) { { id: id, limit: limit } }
          let(:limit) { 2 }

          it 'should be count of requests no more than the limit' do
            expect(subject).to be <= limit
          end
        end

        context 'when `offset` parameter is specified' do
          let(:params) { { id: id, offset: offset } }
          let(:offset) { 2 }

          it 'should be count of requests shifted by offset' do
            expect(subject).to be == 3
          end
        end

        context 'when all supported parameters are specified' do
          let(:params) { { id: id, filter: filter, **paging, order: order } }
          let(:filter) { [{ state: 'ok' }, { rguid: { like: '%000%' } }] }
          let(:paging) { { limit: limit, offset: offset } }
          let(:limit) { 2 }
          let(:offset) { 1 }
          let(:order) { { id: :desc } }

          it 'should be count of filtered requests' do
            expect(subject).to be == 2
          end
        end

        context 'when there are requests of other cases' do
          let(:c4s4) { create(:case) }
          let!(:request) { create(:request, case: c4s4) }
          let!(:attr) { create(:request_attribute, *args) }
          let(:args) { [request: request, name: 'state', value: 'ok'] }
          let(:params) { { id: id, filter: { state: 'ok' } } }

          it 'should be count of requests of the case only' do
            expect(subject).to be == 2
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

  it { is_expected.to respond_to(:find) }

  describe '.find' do
    subject(:result) { described_class.find(params) }

    let(:params) { {} }
    let(:requests_dataset) { CaseCore::Models::Request.dataset }

    context 'when argument is not of Hash type' do
      let(:params) { 'not of Hash type' }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end

    describe 'result' do
      subject { result }

      context 'when no attributes are specified' do
        context 'when there are no request records' do
          it { is_expected.to be_nil }
        end

        context 'when there are request records' do
          let!(:requests) { create_list(:request, 2) }

          it { is_expected.to be_a(CaseCore::Models::Request) }

          it 'should be last created one' do
            expect(result)
              .to be == requests_dataset.order_by(:created_at.desc).first
          end
        end
      end

      context 'when attributes are specified' do
        let(:params) { { name => value } }
        let(:name) { 'name' }
        let(:value) { 'value' }

        context 'when there are no request records' do
          it { is_expected.to be_nil }
        end

        context 'when there are request records' do
          let!(:requests) { create_list(:request, 2) }

          context 'when there is no record with the attributes' do
            it { is_expected.to be_nil }
          end

          context 'when there are records with the attributes' do
            let!(:attr1) { create(:request_attribute, *traits1) }
            let(:traits1) { [request: request1, name: name, value: value] }
            let(:request1) { requests.first }
            let!(:attr2) { create(:request_attribute, *traits2) }
            let(:traits2) { [request: request2, name: name, value: value] }
            let(:request2) { requests.last }

            it { is_expected.to be_a(CaseCore::Models::Request) }

            it 'should be last created one with the attributes' do
              expect(result)
                .to be == requests_dataset.order_by(:created_at.desc).first
            end
          end
        end
      end
    end
  end

  it { is_expected.to respond_to(:index) }

  describe '.index' do
    include described_class::Index::SpecHelper

    subject(:result) { described_class.index(params) }

    let(:params) { { id: id } }

    describe 'result' do
      subject { result }

      let!(:c4s3) { create(:case) }
      let(:id) { c4s3.id }
      let!(:requests) { create_requests(c4s3) }
      let(:schema) { described_class::Index::RESULT_SCHEMA }

      it { is_expected.to match_json_schema(schema) }

      describe 'elements' do
        subject(:ids) { result.map { |hash| hash[:id] } }

        it 'should contain info of requests' do
          expect(ids).to match_array [1, 2, 3, 4, 5]
        end

        context 'when `filter` parameter is specified' do
          let(:params) { { id: id, filter: filter } }

          context 'when the parameter value is a map' do
            context 'when a value of the map is a map' do
              context 'when there is `exclude` key' do
                let(:filter) { { rguid: { exclude: '101' } } }

                it 'should be all infos but selected by `exclude` value' do
                  expect(ids).to match_array [2, 3, 4, 5]
                end
              end

              context 'when there is `like` key' do
                let(:filter) { { rguid: { like: '%000%' } } }

                it 'should be all infos with likely value' do
                  expect(ids).to match_array [3, 4, 5]
                end
              end

              context 'when there is `min` key' do
                let(:filter) { { state: { min: 'error' } } }

                it 'should be all infos with values no less than value' do
                  expect(ids).to match_array [1, 2, 4, 5]
                end
              end

              context 'when there is `max` key' do
                let(:filter) { { state: { max: 'error' } } }

                it 'should be all infos with values no more than value' do
                  expect(ids).to match_array [2, 3]
                end
              end

              context 'when there is more than one supported key specified' do
                let(:filter) { { state: { min: 'error', exclude: 'ok' } } }

                it 'should be all infos selected by all filters together' do
                  expect(ids).to match_array [2, 4]
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
                expect(ids).to match_array [1, 2, 5]
              end
            end

            context 'when a value is not a list nor a map' do
              let(:filter) { { state: 'ok' } }

              it 'should be all infos with the value' do
                expect(ids).to match_array [1, 5]
              end
            end
          end

          context 'when the parameter value is a list' do
            context 'when the list is empty' do
              let(:filter) { [] }

              it 'should be all infos' do
                expect(ids).to match_array [1, 2, 3, 4, 5]
              end
            end

            context 'when the list contains filters' do
              let(:filter) { [{ state: 'ok' }, { op_id: '2abc' }] }

              it 'should be selected by at least one filter' do
                expect(ids).to match_array [1, 2, 5]
              end
            end
          end
        end

        context 'when `limit` parameter is specified' do
          let(:params) { { id: id, limit: limit } }
          let(:limit) { 2 }

          it 'should be no more in quantity than the limit' do
            expect(ids.count).to be <= limit
          end

          context 'when `order` parameter isn\'t specified' do
            it 'should be ordered by `id` field' do
              expect(ids).to be == [1, 2]
            end
          end
        end

        context 'when `offset` parameter is specified' do
          let(:params) { { id: id, offset: offset } }
          let(:offset) { 2 }

          it 'should be shifted by offset' do
            expect(ids).to match_array [3, 4, 5]
          end

          context 'when `order` parameter isn\'t specified' do
            it 'should be ordered by `id` field' do
              expect(ids).to be == [3, 4, 5]
            end
          end
        end

        context 'when `order` parameter is specified' do
          let(:params) { { id: id, order: { id: :desc } } }

          it 'should be ordered by specified fields and directions' do
            expect(ids).to be == [5, 4, 3, 2, 1]
          end
        end

        context 'when `fields` parameter is specified' do
          let(:params) { { id: id, fields: %w[id state] } }

          it 'should contain only specified fields' do
            expect(result.map(&:keys).flatten.uniq).to match_array %i[id state]
          end

          context 'when there is no `id` field in the value' do
            let(:params) { { id: id, fields: %w[state] } }

            it 'should still contain `id` field' do
              expect(result.map(&:keys).flatten.uniq).to include :id
            end
          end
        end

        context 'when all supported parameters are specified' do
          let(:params) { { id: id, filter: filter, **paging, order: order } }
          let(:filter) { [{ state: 'ok' }, { rguid: { like: '%000%' } }] }
          let(:paging) { { limit: limit, offset: offset } }
          let(:limit) { 2 }
          let(:offset) { 1 }
          let(:order) { { id: :desc } }

          it 'should be properly extracted infos' do
            expect(ids).to be == [4, 3]
          end
        end

        context 'when there are requests of other cases' do
          let(:c4s4) { create(:case) }
          let!(:request) { create(:request, case: c4s4) }
          let!(:attr) { create(:request_attribute, *args) }
          let(:args) { [request: request, name: 'state', value: 'ok'] }
          let(:params) { { id: id, filter: filter, order: { id: :asc } } }
          let(:filter) { { state: 'ok' } }

          it 'should be infos of the case only' do
            expect(ids).to be == [1, 5]
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
