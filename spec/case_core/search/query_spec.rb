# frozen_string_literal: true

# Тестирование класса `CaseCore::Search::Query`

CaseCore.need 1

RSpec.describe CaseCore::Search::Query do
  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:dataset) }
  end

  describe '.dataset' do
    include described_class::SpecHelper

    subject(:result) { described_class.dataset(main_model, attr_model, args) }

    let(:main_model) { CaseCore::Models::Case }
    let(:attr_model) { CaseCore::Models::CaseAttribute }
    let(:args) { {} }
    let!(:cases) { create_cases }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(Sequel::Dataset) }

      it 'should be a dataset of main model records' do
        expect(subject.model).to be == main_model
      end

      describe 'records' do
        subject(:ids) { result.select_map(:id) }

        context 'when `filter` parameter is specified' do
          let(:args) { { filter: filter } }

          context 'when the parameter value is a map' do
            context 'when a value of the map is a map' do
              context 'when there is `exclude` key' do
                let(:filter) { { rguid: { exclude: '101' } } }

                it 'should be all records but selected by `exclude` value' do
                  expect(ids).to match_array %w[2 3 4 5]
                end
              end

              context 'when there is only `like` key' do
                let(:filter) { { rguid: { like: '%000%' } } }

                it 'should be all records with likely value' do
                  expect(ids).to match_array %w[3 4 5]
                end
              end

              context 'when there is only `min` key' do
                let(:filter) { { state: { min: 'error' } } }

                it 'should be all records with values no less than value' do
                  expect(ids).to match_array %w[1 2 4 5]
                end
              end

              context 'when there is only `max` key' do
                let(:filter) { { state: { max: 'error' } } }

                it 'should be all records with values no more than value' do
                  expect(ids).to match_array %w[2 3]
                end
              end

              context 'when there are only `min` and `max` keys' do
                let(:filter) { { state: { min: 'error', max: 'error' } } }

                it 'should be all records selected by all filters together' do
                  expect(ids).to match_array %w[2]
                end
              end

              context 'when there is none of supported keys' do
                let(:filter) { { state: { unsupported: :key } } }

                it 'should be all records' do
                  expect(ids).to match_array %w[1 2 3 4 5]
                end
              end
            end

            context 'when a value is a list' do
              let(:filter) { { state: %w[ok error] } }

              it 'should be all records with values from the list' do
                expect(ids).to match_array %w[1 2 5]
              end
            end

            context 'when a value is not a list nor a map' do
              let(:filter) { { state: 'ok' } }

              it 'should be all records with the value' do
                expect(ids).to match_array %w[1 5]
              end
            end
          end
        end

        context 'when `limit` parameter is specified' do
          let(:args) { { limit: limit } }
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
          let(:args) { { offset: offset } }
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
          let(:args) { { order: { type: :asc, id: :desc } } }

          it 'should be ordered by specified fields and directions' do
            expect(ids).to be == %w[5 4 3 2 1]
          end
        end

        context 'when all supported parameters are specified' do
          let(:args) { { filter: filter, **paging, order: order } }
          let(:filter) { { or: filters } }
          let(:filters) { [{ state: 'ok' }, { rguid: { like: '%000%' } }] }
          let(:paging) { { limit: limit, offset: offset } }
          let(:limit) { 2 }
          let(:offset) { 1 }
          let(:order) { { id: :desc } }

          it 'should be properly extracted records' do
            expect(ids).to be == %w[4 3]
          end
        end
      end
    end
  end
end
