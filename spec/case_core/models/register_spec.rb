# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования модели реестра передаваемой корреспонденции
# `CaseCore::Models::Register`
#

RSpec.describe CaseCore::Models::Register do
  describe 'the model' do
    subject { described_class }

    it { is_expected.to respond_to(:create) }
  end

  describe '.create' do
    subject(:result) { described_class.create(params) }

    let(:params) { { register_type: 'cases' } }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(described_class) }
    end

    context 'when register_type is not specified' do
      let(:params) { {} }

      it 'should raise Sequel::NotNullConstraintViolation' do
        expect { subject }.to raise_error(Sequel::NotNullConstraintViolation)
      end
    end

    context 'when register_type is nil' do
      let(:params) { { register_type: nil } }

      it 'should raise Sequel::InvalidValue' do
        expect { subject }.to raise_error(Sequel::InvalidValue)
      end
    end
  end

  describe 'instance of the model' do
    subject(:instance) { create(:register) }

    methods = %i(
      back_office_id
      case_registers
      case_registers_dataset
      cases
      cases_dataset
      exported
      exported_at
      exported_id
      institution_rguid
      office_id
      register_type
      update
    )
    it { is_expected.to respond_to(*methods) }
  end

  describe '#back_office_id' do
    subject(:result) { instance.back_office_id }

    let(:instance) { create(:register) }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is present' do
        it { is_expected.to be_a(String) }
      end

      context 'when value of the corresponding field is absent' do
        let(:instance) { create(:register, back_office_id: nil) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#case_registers' do
    subject(:result) { instance.case_registers }

    let(:instance) { create(:register) }
    let!(:c4s3) { create(:case) }
    let!(:link) { create(:case_register, case: c4s3, register: instance) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_an(Array) }
      it { is_expected.to all(be_a(CaseCore::Models::CaseRegister)) }

      it 'should be a list of links between the register and cases' do
        expect(subject.map(&:register_id).uniq).to be == [instance.id]
      end
    end
  end

  describe '#case_registers_dataset' do
    subject(:result) { instance.case_registers_dataset }

    let(:instance) { create(:register) }
    let!(:c4s3) { create(:case) }
    let!(:link) { create(:case_register, case: c4s3, register: instance) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(Sequel::Dataset) }

      it 'should be a dataset of CaseCore::Models::CaseRegister instances' do
        expect(result.model).to be == CaseCore::Models::CaseRegister
      end

      it 'should be a dataset of records belonging to the instance' do
        expect(result.select_map(:register_id).uniq).to be == [instance.id]
      end
    end
  end

  describe '#cases' do
    subject(:result) { instance.cases }

    let(:instance) { create(:register) }
    let!(:c4s3) { create(:case) }
    let!(:link) { create(:case_register, case: c4s3, register: instance) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_an(Array) }
      it { is_expected.to all(be_a(CaseCore::Models::Case)) }

      it 'should be a list of cases linked to the register' do
        expect(subject.map(&:id))
          .to match_array instance.case_registers.map(&:case_id)
      end
    end
  end

  describe '#cases_dataset' do
    subject(:result) { instance.cases_dataset }

    let(:instance) { create(:register) }
    let!(:c4s3) { create(:case) }
    let!(:link) { create(:case_register, case: c4s3, register: instance) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(Sequel::Dataset) }

      it 'should be a dataset of CaseCore::Models::Case instances' do
        expect(result.model).to be == CaseCore::Models::Case
      end

      it 'should be a dataset of cases linked to the register' do
        expect(result.select_map(:id))
          .to match_array instance.case_registers.map(&:case_id)
      end
    end
  end

  describe '#exported' do
    subject(:result) { instance.exported }

    let(:instance) { create(:register) }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is present' do
        it 'should be boolean' do
          expect(subject).to be_truthy.or be_falsey
        end
      end

      context 'when value of the corresponding field is absent' do
        let(:instance) { create(:register, exported: nil) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#exported_at' do
    subject(:result) { instance.exported_at }

    let(:instance) { create(:register) }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is present' do
        it { is_expected.to be_a(Time) }
      end

      context 'when value of the corresponding field is absent' do
        let(:instance) { create(:register, exported_at: nil) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#exported_id' do
    subject(:result) { instance.exported_id }

    let(:instance) { create(:register) }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is present' do
        it { is_expected.to be_a(String) }
      end

      context 'when value of the corresponding field is absent' do
        let(:instance) { create(:register, exported_id: nil) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#institution_rguid' do
    subject(:result) { instance.institution_rguid }

    let(:instance) { create(:register) }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is present' do
        it { is_expected.to be_a(String) }
      end

      context 'when value of the corresponding field is absent' do
        let(:instance) { create(:register, institution_rguid: nil) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#office_id' do
    subject(:result) { instance.office_id }

    let(:instance) { create(:register) }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is present' do
        it { is_expected.to be_a(String) }
      end

      context 'when value of the corresponding field is absent' do
        let(:instance) { create(:register, office_id: nil) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#register_type' do
    subject(:result) { instance.register_type }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is `cases`' do
        let(:instance) { create(:register, register_type: 'cases') }

        it { is_expected.to be == 'cases' }
      end

      context 'when value of the corresponding field is `requests`' do
        let(:instance) { create(:register, register_type: 'requests') }

        it { is_expected.to be == 'requests' }
      end
    end
  end

  describe '#update' do
    subject { instance.update(params) }

    let(:instance) { create(:register) }

    context 'when id is specified' do
      let(:params) { { id: create(:integer) } }

      it 'should raise Sequel::MassAssignmentRestriction' do
        expect { subject }.to raise_error(Sequel::MassAssignmentRestriction)
      end
    end

    context 'when register_type is specified and wrong' do
      let(:params) { { register_type: 'wrong' } }

      it 'should raise Sequel::DatabaseError' do
        expect { subject }.to raise_error(Sequel::DatabaseError)
      end
    end
  end
end
