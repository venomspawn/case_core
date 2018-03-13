# frozen_string_literal: true

# Файл тестирования класса действия получения информации о количестве заявок

RSpec.describe CaseCore::Actions::Cases::Count do
  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:new) }
  end

  describe '.new' do
    subject(:result) { described_class.new(params) }

    let(:params) { {} }

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

    context 'when argument is of Hash type but of wrong structure' do
      let(:params) { { filter: :wrong } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end
  end

  describe 'instance' do
    subject { described_class.new(params) }

    let(:params) { {} }

    it { is_expected.to respond_to(:count) }
  end

  describe '#count' do
    subject(:result) { instance.count }

    let(:instance) { described_class.new(params) }

    describe 'result' do
      include described_class::SpecHelper

      subject { result }

      let(:params) { {} }
      let!(:cases) { create_cases }

      it { is_expected.to match_json_schema(described_class::RESULT_SCHEMA) }

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
