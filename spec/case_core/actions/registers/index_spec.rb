# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса `CaseCore::Actions::Registers::Index` действий
# получения информации о записях реестров передаваемой корреспонденции
#

RSpec.describe CaseCore::Actions::Registers::Index do
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
      let(:params) { { filter: { wrong: :structure } } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end
  end

  describe 'instance' do
    subject { described_class.new(params) }

    let(:params) { {} }

    it { is_expected.to respond_to(:index) }
  end

  describe '#index' do
    subject(:result) { instance.index }

    let(:instance) { described_class.new(params) }
    let(:params) { {} }

    describe 'result' do
      subject { result }

      let!(:registers) { create_list(:register, 2, :with_cases) }

      it { is_expected.to match_json_schema(described_class::RESULT_SCHEMA) }
    end
  end
end
