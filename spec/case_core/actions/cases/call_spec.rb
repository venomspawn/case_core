# frozen_string_literal: true

# Тестирование класса `CaseCore::Actions::Cases::Call` действия вызова
# метода модуля бизнес-логики с записью заявки в качестве аргумента

RSpec.describe CaseCore::Actions::Cases::Call do
  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:new) }
  end

  describe '.new' do
    subject(:result) { described_class.new(params, rest) }

    let(:params) { { id: :id, method: :a_method } }
    let(:rest) { nil }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(described_class) }
    end

    it_should_behave_like 'an action parameters receiver',
                          params:          { id: :id, method: :a_method },
                          wrong_structure: { wrong: :structure }
  end

  describe 'instance' do
    subject { described_class.new(params) }

    let(:params) { { id: :id, method: :a_method } }

    it { is_expected.to respond_to(:call) }
  end

  describe '#call' do
    subject { instance.call }

    let(:instance) { described_class.new(params) }
    let(:params) { { id: id, method: method_name } }
    let(:id) { c4s3.id }
    let(:c4s3) { create(:case, type: type) }
    let(:type) { 'test_case' }
    let(:method_name) { 'a_method' }

    context 'when case record can\'t be found' do
      let(:id) { 'won\'t be found' }

      it 'should raise Sequel::NoMatchingRow' do
        expect { subject }.to raise_error(Sequel::NoMatchingRow)
      end
    end

    context 'when logic can\'t be found' do
      let(:type) { 'won\'t be found' }

      it 'should raise RuntimeError' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when method is absent' do
      before { CaseCore::Logic::Loader.settings.dir = dir }

      let(:dir) { "#{CaseCore.root}/spec/fixtures/logic" }

      it 'should raise NoMethodError' do
        expect { subject }.to raise_error(NoMethodError)
      end
    end

    context 'when an error appears during call' do
      before do
        CaseCore::Logic::Loader.settings.dir = dir
        allow(logic).to receive(method_name).and_raise('')
      end

      let(:dir) { "#{CaseCore.root}/spec/fixtures/logic" }
      let(:logic) { CaseCore::Logic::Loader.logic(type) }

      it 'should raise the error' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when everything is a\'ight' do
      before do
        CaseCore::Logic::Loader.settings.dir = dir
        allow(logic).to receive(method_name)
      end

      let(:dir) { "#{CaseCore.root}/spec/fixtures/logic" }
      let(:logic) { CaseCore::Logic::Loader.logic(type) }

      it 'should call the method' do
        expect(logic)
          .to receive(method_name)
          .with(instance_of(CaseCore::Models::Case))
        subject
      end
    end
  end
end
