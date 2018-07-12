# frozen_string_literal: true

# Тестирование модели `CaseCore::Models::File` файлов

RSpec.describe CaseCore::Models::File do
  describe 'the model' do
    subject { described_class }

    it { is_expected.to respond_to(:new, :create) }
  end

  describe '.new' do
    subject(:result) { described_class.new(params) }

    describe 'result' do
      subject { result }

      let(:params) { attributes_for(:file).except(:id) }

      it { is_expected.to be_an_instance_of(described_class) }
    end

    context 'when `params` contains `id` attribute' do
      let(:params) { attributes_for(:file) }

      it 'should raise Sequel::MassAssignmentRestriction' do
        expect { subject }.to raise_error(Sequel::MassAssignmentRestriction)
      end
    end
  end

  describe '.create' do
    subject(:result) { described_class.create(params) }

    describe 'result' do
      before { described_class.unrestrict_primary_key }

      after { described_class.restrict_primary_key }

      subject { result }

      let(:params) { attributes_for(:file) }

      it { is_expected.to be_a(described_class) }
    end

    context 'when `params` contains `id` attribute' do
      let(:params) { attributes_for(:file) }

      it 'should raise Sequel::MassAssignmentRestriction' do
        expect { subject }.to raise_error(Sequel::MassAssignmentRestriction)
      end
    end

    context 'when `params` doesn\'t contain `id` attribute' do
      let(:params) { attributes_for(:file).except(:id) }

      it 'should raise Sequel::NotNullConstraintViolation' do
        expect { subject }.to raise_error(Sequel::NotNullConstraintViolation)
      end
    end

    context 'when primary key is unrestricted' do
      before { described_class.unrestrict_primary_key }

      after { described_class.restrict_primary_key }

      context 'when value of `id` property is nil' do
        let(:params) { attributes_for(:file, id: value) }
        let(:value) { nil }

        it 'should raise Sequel::InvalidValue' do
          expect { subject }.to raise_error(Sequel::InvalidValue)
        end
      end

      context 'when value of `id` property is of String' do
        context 'when the value is not of UUID format' do
          let(:params) { attributes_for(:file, id: value) }
          let(:value) { 'not of UUID format' }

          it 'should raise Sequel::DatabaseError' do
            expect { subject }.to raise_error(Sequel::DatabaseError)
          end
        end
      end

      context 'when value of `content` property is nil' do
        let(:params) { attributes_for(:file, content: value) }
        let(:value) { nil }

        it 'should raise Sequel::InvalidValue' do
          expect { subject }.to raise_error(Sequel::InvalidValue)
        end
      end

      context 'when value of `created_at` property is nil' do
        let(:params) { attributes_for(:file, created_at: value) }
        let(:value) { nil }

        it 'should raise Sequel::InvalidValue' do
          expect { subject }.to raise_error(Sequel::InvalidValue)
        end
      end

      context 'when value of `created_at` property is of String' do
        context 'when the value is not a time\'s representation' do
          let(:params) { attributes_for(:file, traits) }
          let(:traits) { { created_at: value } }
          let(:value) { 'not a time\'s representation' }

          it 'should raise Sequel::InvalidValue' do
            expect { subject }.to raise_error(Sequel::InvalidValue)
          end
        end
      end
    end
  end

  describe 'instance of the model' do
    subject(:instance) { create(:file) }

    it { is_expected.to respond_to(:id, :content, :created_at) }
  end

  describe '#id' do
    subject(:result) { instance.id }

    describe 'result' do
      subject { result }

      let(:instance) { create(:file) }

      it { is_expected.to be_a(String) }

      it 'should be an UUID' do
        hex = '[0-9a-zA-Z]'
        expect(subject)
          .to match(/^#{hex}{8}-#{hex}{4}-#{hex}{4}-#{hex}{4}-#{hex}{12}$/)
      end
    end
  end

  describe '#content' do
    subject(:result) { instance.content }

    let(:instance) { create(:file) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(String) }
    end
  end

  describe '#created_at' do
    subject(:result) { instance.created_at }

    let(:instance) { create(:file) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(Time) }
    end
  end

  describe '#update' do
    subject(:result) { instance.update(params) }

    let(:instance) { create(:file) }

    context 'when id is specified' do
      let(:params) { { id: create(:uuid) } }

      it 'should raise Sequel::MassAssignmentRestriction' do
        expect { subject }.to raise_error(Sequel::MassAssignmentRestriction)
      end
    end

    context 'when `content` property is present in parameters' do
      let(:params) { { content: value } }

      context 'when the value is of String' do
        let(:value) { create(:string) }

        it 'should set `content` attribute of the instance to the value' do
          expect { subject }.to change { instance.content }.to(value)
        end
      end

      context 'when the value is nil' do
        let(:value) { nil }

        it 'should raise Sequel::InvalidValue' do
          expect { subject }.to raise_error(Sequel::InvalidValue)
        end
      end
    end

    context 'when `created_at` property is present in parameters' do
      let(:params) { { created_at: value } }

      context 'when the value is of String' do
        context 'when the value is a time\'s representation' do
          before { subject }

          let(:value) { created_at.to_s }
          let(:created_at) { Time.now - 1 }

          it 'should set `created_at` attribute to the date' do
            expect(instance.created_at).to be_within(1).of(created_at)
          end
        end

        context 'when the value is not a time\'s representation' do
          let(:value) { 'not a time\'s representation' }

          it 'should raise Sequel::InvalidValue' do
            expect { subject }.to raise_error(Sequel::InvalidValue)
          end
        end
      end

      context 'when the value is of Time' do
        before { subject }

        let(:value) { Time.now - 1 }

        it 'should set `created_at` attribute to the value' do
          expect(instance.created_at).to be_within(1).of(value)
        end
      end

      context 'when the value is nil' do
        let(:value) { nil }

        it 'should raise Sequel::InvalidValue' do
          expect { subject }.to raise_error(Sequel::InvalidValue)
        end
      end
    end
  end
end
