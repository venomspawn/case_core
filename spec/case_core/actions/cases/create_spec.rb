# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса действия создания записи заявки
#

RSpec.describe CaseCore::Actions::Cases::Create do
  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:new) }
  end

  describe '.new' do
    subject(:result) { described_class.new(params) }

    let(:params) { { type: :type } }

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

    context 'when argument is of Hash type but is of wrong structure' do
      let(:params) { { type: { wrong: :structure } } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end
  end

  describe 'instance' do
    subject { described_class.new(params) }

    let(:params) { { type: :type } }

    it { is_expected.to respond_to(:create) }
  end

  describe '#create' do
    subject { instance.create }

    let(:instance) { described_class.new(params) }
    let(:params) { { type: :type } }

    it 'should create a record of `CaseCore::Models::Case` model' do
      expect { subject }.to change { CaseCore::Models::Case.count }.by(1)
    end

    context 'when `id` attribute is not specified' do
      it 'should create value of the attribute' do
        expect { subject }.to change { CaseCore::Models::Case.count }.by(1)
      end
    end

    context 'when `id` attribute is specified' do
      let(:params) { { id: id, type: :type } }
      let(:id) { 'id' }

      context 'when a record with the value exists' do
        let!(:case) { create(:case, id: :id, type: :type) }

        it 'should raise Sequel::UniqueConstraintViolation' do
          expect { subject }.to raise_error(Sequel::UniqueConstraintViolation)
        end
      end

      context 'when a record with the value doesn\'t exist' do
        let(:c4s3) { CaseCore::Models::Case.last }

        it 'should use specified value' do
          subject
          expect(c4s3.id).to be == id
        end
      end
    end

    context 'when there are attributes besides `id` and `type`' do
      let(:params) { { type: :type, attr1: :value1, attr2: :value2 } }

      it 'should create records of `CaseCore::Models::CaseAttribute` model' do
        expect { subject }
          .to change { CaseCore::Models::CaseAttribute.count }
          .by(2)
      end
    end

    context 'when there are documents linked to the case' do
      let(:params) { { type: :type, documents: [{ id: :id }, { id: :id2 }] } }

      it 'should create records of `CaseCore::Models::Document` model' do
        expect { subject }.to change { CaseCore::Models::Document.count }.by(2)
      end
    end

    context 'when there is a module to notify about case creation' do
      before do
        CaseCore::Logic::Loader.settings.dir = dir
        allow(logic).to receive(:on_case_creation)
      end

      let(:params) { { type: type } }
      let(:dir) { "#{$root}/spec/fixtures/logic" }
      let(:type) { 'test_case' }
      let(:logic) { CaseCore::Logic::Loader.logic(type) }

      it 'should notify the module' do
        expect(logic)
          .to receive(:on_case_creation)
          .with(CaseCore::Models::Case)
        subject
      end
    end
  end
end
