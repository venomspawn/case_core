# frozen_string_literal: true

# Тестирование класса действия получения информации о версии сервиса и
# модулей бизнес-логики

RSpec.describe CaseCore::Actions::Version::Show do
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
      let(:params) { %w[not of Hash type] }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end
  end

  describe 'instance' do
    subject { described_class.new(params) }

    let(:params) { {} }

    it { is_expected.to respond_to(:show) }
  end

  describe '#show' do
    include described_class::SpecHelper

    subject(:result) { instance.show }

    let(:instance) { described_class.new(params) }
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
  end
end
