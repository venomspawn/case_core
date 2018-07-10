# frozen_string_literal: true

# Файл тестирования класса `CaseCore::Actions::Requests::Count` действия
# получения информации о количестве межведомственных запросах, созданных в
# рамках заявки

RSpec.describe CaseCore::Actions::Requests::Count do
  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:new) }
  end

  describe '.new' do
    subject(:result) { described_class.new(params, rest) }

    let(:params) { { id: id } }
    let(:id) { 'id' }
    let(:rest) { nil }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(described_class) }
    end

    it_should_behave_like 'an action parameters receiver',
                          params:          { id: 'id' },
                          wrong_structure: {}
  end

  describe 'instance' do
    subject { described_class.new(params) }

    let(:params) { { id: id } }
    let(:id) { 'id' }

    it { is_expected.to respond_to(:count) }
  end

  describe '#count' do
    include described_class::SpecHelper

    subject(:result) { instance.count }

    let(:instance) { described_class.new(params) }
    let(:params) { { id: id } }

    describe 'result' do
      subject { result }

      let!(:c4s3) { create(:case) }
      let(:id) { c4s3.id }
      let!(:requests) { create_requests(c4s3) }

      it { is_expected.to match_json_schema(described_class::RESULT_SCHEMA) }

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

              context 'when there is only `like` key' do
                let(:filter) { { rguid: { like: '%000%' } } }

                it 'should be count of requests filtered by likely value' do
                  expect(subject).to be == 3
                end
              end

              context 'when there is only `min` key' do
                let(:filter) { { state: { min: 'error' } } }

                it 'should be count of requests with no less values' do
                  expect(subject).to be == 4
                end
              end

              context 'when there is only `max` key' do
                let(:filter) { { state: { max: 'error' } } }

                it 'should be count of requests with no more values' do
                  expect(subject).to be == 2
                end
              end

              context 'when there are only `min` and `max` keys' do
                let(:filter) { { state: { min: 'error', max: 'error' } } }

                it 'should be count of cases filtered by filters together' do
                  expect(subject).to be == 1
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

            context 'when there is only `or` key' do
              let(:filter) { { or: [{ state: 'ok' }, { op_id: '2abc' }] } }

              it 'should be count of cases selected by at least one filter' do
                expect(subject).to be == 3
              end
            end

            context 'when there is only `and` key' do
              let(:filter) { { and: [{ state: 'ok' }, { op_id: '2abc' }] } }

              it 'should be count of cases selected by all filters' do
                expect(subject).to be == 0
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
          let(:filter) { { or: filters } }
          let(:filters) { [{ state: 'ok' }, { rguid: { like: '%000%' } }] }
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

    context 'when case record can\'t be found by provided id' do
      let(:id) { 'won\'t be found' }

      it 'should raise Sequel::NoMatchingRow' do
        expect { subject }.to raise_error(Sequel::NoMatchingRow)
      end
    end
  end
end
