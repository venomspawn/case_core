# frozen_string_literal: true

# Файл тестирования класса `CaseCore::Actions::Requests::Index` действия
# получения информации о межведомственных запросах, созданных в рамках заявки

RSpec.describe CaseCore::Actions::Requests::Index do
  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:new) }
  end

  describe '.new' do
    subject(:result) { described_class.new(params) }

    let(:params) { { id: id } }
    let(:id) { 'id' }

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

    context 'when argument is of Hash type but doesn\'t have `id` attribute' do
      let(:params) { { doesnt: :have_id_attribute } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end
  end

  describe 'instance' do
    subject { described_class.new(params) }

    let(:params) { { id: id } }
    let(:id) { 'id' }

    it { is_expected.to respond_to(:index) }
  end

  describe '#index' do
    include described_class::SpecHelper

    subject(:result) { instance.index }

    let(:instance) { described_class.new(params) }
    let(:params) { { id: id } }

    describe 'result' do
      subject { result }

      let!(:c4s3) { create(:case) }
      let(:id) { c4s3.id }
      let!(:requests) { create_requests(c4s3) }
      let(:id1) { requests[0].id }
      let(:id2) { requests[1].id }
      let(:id3) { requests[2].id }
      let(:id4) { requests[3].id }
      let(:id5) { requests[4].id }

      it { is_expected.to match_json_schema(described_class::RESULT_SCHEMA) }

      describe 'elements' do
        subject(:ids) { result.map { |hash| hash[:id] } }

        it 'should contain info of requests' do
          expect(ids).to match_array [id1, id2, id3, id4, id5]
        end

        context 'when `filter` parameter is specified' do
          let(:params) { { id: id, filter: filter } }

          context 'when the parameter value is a map' do
            context 'when a value of the map is a map' do
              context 'when there is only `exclude` key' do
                let(:filter) { { rguid: { exclude: '101' } } }

                it 'should be all infos but selected by `exclude` value' do
                  expect(ids).to match_array [id2, id3, id4, id5]
                end
              end

              context 'when there is only `like` key' do
                let(:filter) { { rguid: { like: '%000%' } } }

                it 'should be all infos with likely value' do
                  expect(ids).to match_array [id3, id4, id5]
                end
              end

              context 'when there is only `min` key' do
                let(:filter) { { state: { min: 'error' } } }

                it 'should be all infos with values no less than value' do
                  expect(ids).to match_array [id1, id2, id4, id5]
                end
              end

              context 'when there is only `max` key' do
                let(:filter) { { state: { max: 'error' } } }

                it 'should be all infos with values no more than value' do
                  expect(ids).to match_array [id2, id3]
                end
              end

              context 'when there are only `min` and `max` keys' do
                let(:filter) { { state: { min: 'error', max: 'error' } } }

                it 'should be all infos selected by all filters together' do
                  expect(ids).to match_array [id2]
                end
              end
            end

            context 'when a value is a list' do
              let(:filter) { { state: %w[ok error] } }

              it 'should be all infos with values from the list' do
                expect(ids).to match_array [id1, id2, id5]
              end
            end

            context 'when a value is not a list nor a map' do
              let(:filter) { { state: 'ok' } }

              it 'should be all infos with the value' do
                expect(ids).to match_array [id1, id5]
              end
            end

            context 'when there is only `or` key' do
              let(:filter) { { or: [{ state: 'ok' }, { op_id: '2abc' }] } }

              it 'should be infos selected by at least one filter' do
                expect(ids).to match_array [id1, id2, id5]
              end
            end

            context 'when there is only `and` key' do
              let(:filter) { { and: [{ state: 'ok' }, { op_id: '2abc' }] } }

              it 'should be infos selected by all filters' do
                expect(ids).to match_array []
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
              expect(ids).to be == [id1, id2]
            end
          end
        end

        context 'when `offset` parameter is specified' do
          let(:params) { { id: id, offset: offset } }
          let(:offset) { 2 }

          it 'should be shifted by offset' do
            expect(ids).to match_array [id3, id4, id5]
          end

          context 'when `order` parameter isn\'t specified' do
            it 'should be ordered by `id` field' do
              expect(ids).to be == [id3, id4, id5]
            end
          end
        end

        context 'when `order` parameter is specified' do
          let(:params) { { id: id, order: { id: :desc } } }

          it 'should be ordered by specified fields and directions' do
            expect(ids).to be == [id5, id4, id3, id2, id1]
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
          let(:filter) { { or: filters } }
          let(:filters) { [{ state: 'ok' }, { rguid: { like: '%000%' } }] }
          let(:paging) { { limit: limit, offset: offset } }
          let(:limit) { 2 }
          let(:offset) { 1 }
          let(:order) { { id: :desc } }

          it 'should be properly extracted infos' do
            expect(ids).to be == [id4, id3]
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
            expect(ids).to be == [id1, id5]
          end
        end
      end
    end

    context 'when case record can\'t be found by provided id' do
      let(:id) { 'won\'t be found' }

      it 'should raise Sequel::NoMatchingRow' do
        expect { subject }.to raise_error(Sequel::NoMatchingRow)
      end
    end
  end
end
