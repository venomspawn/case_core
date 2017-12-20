# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования функций модуля `CaseCore::Actions::Registers`
#

RSpec.describe CaseCore::Actions::Registers do
  subject { described_class }

  it { is_expected.to respond_to(:export) }

  describe '.export' do
    subject { described_class.export(params) }

    let(:params) { { id: id } }

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

    context 'when `arguments` parameter is not of Array type' do
      let(:params) { { id: 1, arguments: 'not of Array type' } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end

    context 'when a parameter beside `id` and `arguments` is present' do
      let(:params) { { id: 1, a: :parameter } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end

    context 'when register can\'t be found by record id' do
      let(:id) { 100_500 }

      it 'should raise Sequel::NoMatchingRow' do
        expect { subject }.to raise_error(Sequel::NoMatchingRow)
      end
    end

    context 'when register is empty' do
      let(:id) { register.id }
      let(:register) { create(:register) }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when logic can\'t be found by first case' do
      before { CaseCore::Logic::Loader.settings.dir = dir }

      let(:dir) { "#{$root}/spec/fixtures/logic" }
      let(:id) { register.id }
      let(:register) { create(:register) }
      let(:c4s3) { create(:case, type: 'wrong') }
      let!(:link) { create(:case_register, case: c4s3, register: register) }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when logic doesn\'t provide `export_register` method' do
      before { CaseCore::Logic::Loader.settings.dir = dir }

      let(:dir) { "#{$root}/spec/fixtures/logic" }
      let(:id) { register.id }
      let(:register) { create(:register) }
      let(:c4s3) { create(:case, type: 'test_case') }
      let!(:link) { create(:case_register, case: c4s3, register: register) }

      it 'should raise NoMethodError' do
        expect { subject }.to raise_error(NoMethodError)
      end
    end

    context 'when everything is a\'ight' do
      before do
        CaseCore::Logic::Loader.settings.dir = dir
        allow(logic).to receive(:export_register)
      end

      let(:dir) { "#{$root}/spec/fixtures/logic" }
      let(:logic) { CaseCore::Logic::Loader.logic(type) }
      let(:type) { 'test_case' }
      let(:id) { register.id }
      let(:register) { create(:register) }
      let(:c4s3) { create(:case, type: type) }
      let!(:link) { create(:case_register, case: c4s3, register: register) }

      it 'should call `export_register` method' do
        expect(logic)
          .to receive(:export_register)
          .with(instance_of(CaseCore::Models::Register))
        subject
      end

      context 'when arguments are provided' do
        let(:params) { { id: id, arguments: arguments } }
        let(:arguments) { [a: :b] }

        it 'should call `export_register` function with the arguments' do
          expect(logic)
            .to receive(:export_register)
            .with(instance_of(CaseCore::Models::Register), *arguments)
          subject
        end
      end
    end
  end

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

  it { is_expected.to respond_to(:show) }

  describe '.show' do
    subject(:result) { described_class.show(params) }

    let(:params) { { id: id } }

    describe 'result' do
      subject { result }

      let(:register) { create(:register, :with_cases) }
      let(:id) { register.id }
      let(:schema) { described_class::Show::RESULT_SCHEMA }

      it { is_expected.to match_json_schema(schema) }
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
      let(:id) { 100_500 }

      it 'should raise Sequel::NoMatchingRow' do
        expect { subject }.to raise_error(Sequel::NoMatchingRow)
      end
    end
  end
end
