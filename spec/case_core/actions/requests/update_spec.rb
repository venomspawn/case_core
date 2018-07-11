# frozen_string_literal: true

# Тестирование класса действия обновления атрибутов межведомственного
# запроса

RSpec.describe CaseCore::Actions::Requests::Update do
  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:new) }
  end

  describe '.new' do
    subject(:result) { described_class.new(params, rest) }

    let(:params) { { id: 1, attr: 'attr' } }
    let(:rest) { nil }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(described_class) }
    end

    it_should_behave_like 'an action parameters receiver',
                          params:          { id: 1, attr: 'attr' },
                          wrong_structure: {}
  end

  describe 'instance' do
    subject { described_class.new(params) }

    let(:params) { { id: 1, attr: 'attr' } }

    it { is_expected.to respond_to(:update) }
  end

  describe '#update' do
    subject { instance.update }

    let(:instance) { described_class.new(params) }
    let(:params) { { id: id, name.to_sym => new_value } }
    let(:request) { create(:request, case: c4s3) }
    let(:c4s3) { create(:case) }
    let(:id) { request.id }
    let!(:attr) { create(:request_attribute, *attr_traits) }
    let(:attr_traits) { [request: request, name: name, value: value] }
    let(:name) { 'attr' }
    let(:value) { 'value' }
    let(:new_value) { 'new_value' }

    it 'should update attributes of the request' do
      expect { subject }
        .to change { CaseCore::Actions::Requests.show(id: id)[name] }
        .from(value)
        .to(new_value)
    end

    context 'when request record isn\'t found' do
      let(:id) { 100_500 }

      it 'should raise Sequel::ForeignKeyConstraintViolation' do
        expect { subject }
          .to raise_error(Sequel::ForeignKeyConstraintViolation)
      end
    end
  end
end
