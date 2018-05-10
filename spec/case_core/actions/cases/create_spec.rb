# frozen_string_literal: true

# Файл тестирования класса действия создания записи заявки

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
    before { CaseCore::Logic::Loader.settings.dir = dir }

    subject { instance.create }

    let(:instance) { described_class.new(params) }
    let(:dir) { "#{$root}/spec/fixtures/logic" }
    let(:params) { { type: type, **attrs, **documents } }
    let(:attrs) { {} }
    let(:documents) { {} }

    context 'when there is no module of business logic for the case' do
      let(:type) { 'no module for the case' }
      let(:attrs) { { attr1: :value1, attr2: :value2 } }
      let(:documents) { { documents: [{ id: 'id' }, { id: 'id2' }] } }

      it 'should raise `RuntimeError`' do
        expect { subject }.to raise_error(RuntimeError)
      end

      it 'shouldn\'t create case records' do
        expect { subject }
          .to raise_error(RuntimeError)
          .and change { CaseCore::Models::Case.count }.by(0)
      end

      it 'shouldn\'t create records of case attributes' do
        expect { subject }
          .to raise_error(RuntimeError)
          .and change { CaseCore::Models::CaseAttribute.count }.by(0)
      end

      it 'shouldn\'t create records of documents' do
        expect { subject }
          .to raise_error(RuntimeError)
          .and change { CaseCore::Models::Document.count }.by(0)
      end
    end

    context 'when there is a module of business logic for the case' do
      let(:type) { 'test_case' }

      context 'when the module doesn\'t provide `on_case_creation` function' do
        let(:attrs) { { attr1: :value1, attr2: :value2 } }
        let(:documents) { { documents: [{ id: 'id' }, { id: 'id2' }] } }

        it 'should raise `RuntimeError`' do
          expect { subject }.to raise_error(RuntimeError)
        end

        it 'shouldn\'t create case records' do
          expect { subject }
            .to raise_error(RuntimeError)
            .and change { CaseCore::Models::Case.count }.by(0)
        end

        it 'shouldn\'t create records of case attributes' do
          expect { subject }
            .to raise_error(RuntimeError)
            .and change { CaseCore::Models::CaseAttribute.count }.by(0)
        end

        it 'shouldn\'t create records of documents' do
          expect { subject }
            .to raise_error(RuntimeError)
            .and change { CaseCore::Models::Document.count }.by(0)
        end
      end

      context 'when the module provides `on_case_creation` function' do
        before { allow(logic).to receive(:on_case_creation) }

        let(:logic) { CaseCore::Logic::Loader.logic(type) }

        it 'should call the function' do
          expect(logic)
            .to receive(:on_case_creation)
            .with(CaseCore::Models::Case)
          subject
        end

        context 'when the function raises `ArgumentError`' do
          before do
            allow(logic).to receive(:on_case_creation).and_raise(error)
          end

          let(:error) { ArgumentError.new }
          let(:attrs) { { attr1: :value1, attr2: :value2 } }
          let(:documents) { { documents: [{ id: 'id' }, { id: 'id2' }] } }

          it 'should raise the error' do
            expect { subject }.to raise_error(error)
          end

          it 'shouldn\'t create case records' do
            expect { subject }
              .to raise_error(error)
              .and change { CaseCore::Models::Case.count }.by(0)
          end

          it 'shouldn\'t create records of case attributes' do
            expect { subject }
              .to raise_error(error)
              .and change { CaseCore::Models::CaseAttribute.count }.by(0)
          end

          it 'shouldn\'t create records of documents' do
            expect { subject }
              .to raise_error(error)
              .and change { CaseCore::Models::Document.count }.by(0)
          end
        end

        context 'when the function raises other errors' do
          before do
            allow(logic).to receive(:on_case_creation).and_raise(NameError)
          end

          it 'should create a record of `CaseCore::Models::Case` model' do
            expect { subject }.to change { CaseCore::Models::Case.count }.by(1)
          end

          context 'when `id` attribute is not specified' do
            it 'should create value of the attribute' do
              expect { subject }
                .to change { CaseCore::Models::Case.count }
                .by(1)
            end
          end

          context 'when `id` attribute is specified' do
            let(:params) { { id: id, type: type } }
            let(:id) { 'id' }

            context 'when a record with the value exists' do
              let!(:case) { create(:case, id: :id, type: type) }

              it 'should raise Sequel::UniqueConstraintViolation' do
                expect { subject }
                  .to raise_error(Sequel::UniqueConstraintViolation)
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
            let(:attrs) { { attr1: :value1, attr2: :value2 } }

            it 'should create records of case attributes' do
              expect { subject }
                .to change { CaseCore::Models::CaseAttribute.count }
                .by(2)
            end
          end

          context 'when there are documents linked to the case' do
            let(:documents) { { documents: [{ id: 'id' }, { id: 'id2' }] } }

            it 'should create records of documents' do
              expect { subject }
                .to change { CaseCore::Models::Document.count }
                .by(2)
            end
          end
        end

        context 'when the function doesn\'t raise an error' do
          it 'should create a record of `CaseCore::Models::Case` model' do
            expect { subject }.to change { CaseCore::Models::Case.count }.by(1)
          end

          context 'when `id` attribute is not specified' do
            it 'should create value of the attribute' do
              expect { subject }
                .to change { CaseCore::Models::Case.count }
                .by(1)
            end
          end

          context 'when `id` attribute is specified' do
            let(:params) { { id: id, type: type } }
            let(:id) { 'id' }

            context 'when a record with the value exists' do
              let!(:case) { create(:case, id: :id, type: type) }

              it 'should raise Sequel::UniqueConstraintViolation' do
                expect { subject }
                  .to raise_error(Sequel::UniqueConstraintViolation)
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
            let(:attrs) { { attr1: :value1, attr2: :value2 } }

            it 'should create records of case attributes' do
              expect { subject }
                .to change { CaseCore::Models::CaseAttribute.count }
                .by(2)
            end
          end

          context 'when there are documents linked to the case' do
            let(:documents) { { documents: [{ id: 'id' }, { id: 'id2' }] } }

            it 'should create records of documents' do
              expect { subject }
                .to change { CaseCore::Models::Document.count }
                .by(2)
            end

            context 'when the documents lack id value' do
              let(:documents) { { documents: [{}] } }

              it 'should create id' do
                expect { subject }
                  .to change { CaseCore::Models::Document.count }
                  .by(1)
              end
            end
          end
        end
      end
    end
  end
end
