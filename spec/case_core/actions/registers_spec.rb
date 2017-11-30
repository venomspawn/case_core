# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования функций модуля `CaseCore::Actions::Registers`
#

RSpec.describe CaseCore::Actions::Registers do
  subject { described_class }

  it { is_expected.to respond_to(:index) }

  describe '.index' do
    subject(:result) { described_class.index(params) }

    let(:params) { {} }

    describe 'result' do
      subject { result }

      let!(:registers) { create_list(:register, 2, :with_cases) }
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
      let(:params) { { filter: { wrong: :structure } } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end
  end
end
