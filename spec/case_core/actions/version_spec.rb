# frozen_string_literal: true

# Тестирование функций модуля `CaseCore::Actions::Version`

RSpec.describe CaseCore::Actions::Version do
  describe 'the module' do
    subject { described_class }

    it { is_expected.to respond_to(:show) }
  end

  describe '.show' do
    include described_class::Show::SpecHelper

    subject(:result) { described_class.show(params) }

    let(:params) { {} }

    describe 'result' do
      subject { result }

      it { is_expected.to match_json_schema(schema) }

      context 'when there appears `modules` parameter' do
        let(:params) { { modules: nil } }

        it 'should include modules version info' do
          expect(subject).to include(:modules)
        end
      end
    end

    context 'when argument is not of Hash type' do
      let(:params) { %w[not of Hash type] }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end
  end
end
