# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования модели связи между реестрами передаваемой корреспонденции и
# заявками `CaseCore::Models::CaseRegister`
#

RSpec.describe CaseCore::Models::CaseRegister do
  describe 'the model' do
    subject { described_class }

    it { is_expected.to respond_to(:create) }
  end

  describe '.create' do
    subject(:result) { described_class.create(params) }

    let(:params) { { case: c4s3, register: register } }
    let(:c4s3) { create(:case) }
    let(:register) { create(:register) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(described_class) }
    end

    context 'when neither case nor case_id are specified' do
      let(:params) { { register: register } }

      it 'should raise Sequel::NotNullConstraintViolation' do
        expect { subject }.to raise_error(Sequel::NotNullConstraintViolation)
      end
    end

    context 'when neither register nor register_id are specified' do
      let(:params) { { case: c4s3 } }

      it 'should raise Sequel::NotNullConstraintViolation' do
        expect { subject }.to raise_error(Sequel::NotNullConstraintViolation)
      end
    end
  end

  describe 'instance of the model' do
    subject(:instance) { create(:case_register) }

    methods = %i(case case_id register register_id)
    it { is_expected.to respond_to(*methods) }
  end

  describe '#case' do
    subject(:result) { instance.case }

    let(:instance) { create(:case_register) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(CaseCore::Models::Case) }

      it 'should be a record which this record belongs to' do
        expect(result.id) == instance.case_id
      end
    end
  end

  describe '#case_id' do
    subject(:result) { instance.case_id }

    let(:instance) { create(:case_register) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(String) }
    end
  end

  describe '#register' do
    subject(:result) { instance.register }

    let(:instance) { create(:case_register) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(CaseCore::Models::Register) }

      it 'should be a record which this record belongs to' do
        expect(result.id) == instance.register_id
      end
    end
  end

  describe '#register_id' do
    subject(:result) { instance.register_id }

    let(:instance) { create(:case_register) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(Integer) }
    end
  end
end
