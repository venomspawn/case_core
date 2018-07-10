# frozen_string_literal: true

# Файл тестирования класса действия обновления атрибутов заявки

RSpec.describe CaseCore::Actions::Cases::Update do
  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:new) }
  end

  describe '.new' do
    subject(:result) { described_class.new(params, rest) }

    let(:params) { { id: 'id', attr: 'attr' } }
    let(:rest) { nil }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(described_class) }
    end

    it_should_behave_like 'an action parameters receiver',
                          params:          { id: 'id', attr: 'attr' },
                          wrong_structure: {}
  end

  describe 'instance' do
    subject { described_class.new(params) }

    let(:params) { { id: 'id', attr: 'attr' } }

    it { is_expected.to respond_to(:update) }
  end

  describe '#update' do
    subject { instance.update }

    let(:instance) { described_class.new(params) }
    let(:params) { { id: id, name.to_sym => new_value } }
    let(:c4s3) { create(:case) }
    let(:id) { c4s3.id }
    let!(:attr) { create(:case_attribute, *attr_traits) }
    let(:attr_traits) { [case: c4s3, name: name, value: value] }
    let(:name) { 'attr' }
    let(:value) { 'value' }
    let(:new_value) { 'new_value' }
    let(:show) { CaseCore::Actions::Cases.method(:show_attributes) }

    it 'should update attributes of the case' do
      expect { subject }
        .to change { show[id: id][name.to_sym] }
        .from(value)
        .to(new_value)
    end

    context 'when many case identifiers are specified' do
      let(:c4s4) { create(:case) }
      let!(:another_attr) { create(:case_attribute, *another_attr_traits) }
      let(:another_attr_traits) { [case: c4s4, name: name, value: value] }
      let(:id3) { c4s3.id }
      let(:id4) { c4s4.id }
      let(:id) { [id3, id4] }

      it 'should update attributes of the cases' do
        expect { subject }
          .to change { show[id: id3][name.to_sym] }
          .from(value)
          .to(new_value)
          .and change { show[id: id3][name.to_sym] }
          .from(value)
          .to(new_value)
      end

      context 'when at least one update brings an error' do
        let(:id4) { 'brings an error' }

        it 'should raise the error' do
          expect { subject }
            .to raise_error(Sequel::ForeignKeyConstraintViolation)
        end

        it 'shouldn\'t update attributes of the cases' do
          expect { subject }
            .to raise_error(Sequel::ForeignKeyConstraintViolation)
            .and not_change { show[id: id3][name.to_sym] }
          expect { subject }
            .to raise_error(Sequel::ForeignKeyConstraintViolation)
            .and not_change { show[id: id4][name.to_sym] }
        end
      end
    end

    context 'when request record isn\'t found' do
      let(:id) { 'won\'t be found' }

      it 'should raise Sequel::ForeignKeyConstraintViolation' do
        expect { subject }
          .to raise_error(Sequel::ForeignKeyConstraintViolation)
      end
    end
  end
end
