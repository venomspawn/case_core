# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса `CaseCore::Actions::Registers::Export` действий,
# которые вызывают функцию `export_register` модуля бизнес-логики первой
# заявки, находящейся в реестре передаваемой корреспонденции
#

RSpec.describe CaseCore::Actions::Registers::Export do
  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:new) }
  end

  describe '.new' do
    subject(:result) { described_class.new(params) }

    let(:params) { { id: 1 } }

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

    context 'when `id` parameter is absent' do
      let(:params) { {} }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end

    context 'when a parameter beside `id` is present' do
      let(:params) { { id: 1, a: :parameter } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end
  end

  describe 'instance' do
    subject { described_class.new(params) }

    let(:params) { { id: 1 } }

    it { is_expected.to respond_to(:export) }
  end

  describe '#export' do
    subject { instance.export }

    let(:instance) { described_class.new(params) }
    let(:params) { { id: id } }

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
    end
  end
end
