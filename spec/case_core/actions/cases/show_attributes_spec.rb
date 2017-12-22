# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса действия получения информации об атрибуах заявки,
# кроме тех, что присутствуют непосредственно в записи заявки
#

RSpec.describe CaseCore::Actions::Cases::ShowAttributes do
  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:new) }
  end

  describe '.new' do
    subject(:result) { described_class.new(params) }

    let(:params) { { id: id } }
    let(:id) { 'id' }

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

    context 'when `names` parameter is not `nil` nor a list' do
      let(:params) { { id: 'id', names: 'not `nil` nor a list' } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end

    context 'when `names` parameter contains an element of wrong type' do
      let(:params) { { id: 'id', names: [wrong: :type] } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end

    context 'when `names` parameter contains `id` string' do
      let(:params) { { id: 'id', names: %w(attr id) } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end

    context 'when `names` parameter contains `type` string' do
      let(:params) { { id: 'id', names: %w(attr type) } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end

    context 'when `names` parameter contains `created_at` string' do
      let(:params) { { id: 'id', names: %w(attr created_at) } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end

    context 'when a parameter beside `id` or `name` is present' do
      let(:params) { { id: 'id', names: [], a: :parameter } }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end
  end

  describe 'instance' do
    subject { described_class.new(params) }

    let(:params) { { id: id } }
    let(:id) { 'id' }

    it { is_expected.to respond_to(:show_attributes) }
  end

  describe '#show' do
    subject(:result) { instance.show_attributes }

    let(:instance) { described_class.new(params) }
    let(:params) { { id: id } }

    describe 'result' do
      subject { result }

      let(:c4s3) { create(:case) }
      let(:id) { c4s3.id }
      let!(:attribute1) { create(:case_attribute, case: c4s3) }
      let!(:attribute2) { create(:case_attribute, case: c4s3) }
      let(:name1) { attribute1.name.to_sym }
      let(:name2) { attribute2.name.to_sym }
      let(:value1) { attribute1.value }
      let(:value2) { attribute2.value }

      it { is_expected.to be_a(Hash) }
      it { is_expected.to match_json_schema(described_class::RESULT_SCHEMA) }

      describe 'keys' do
        subject { result.keys }

        it { is_expected.to all(be_a(Symbol)) }
      end

      context 'when case record can\'t be found' do
        let(:id) { 'won\'t be found' }

        it { is_expected.to be_empty }
      end

      context 'when `names` parameter is absent`' do
        it 'should extract all attributes' do
          expect(subject).to be == { name1 => value1, name2 => value2 }
        end
      end

      context 'when `names` parameter is nil`' do
        let(:params) { { id: id, names: nil } }

        it 'should extract all attributes' do
          expect(subject).to be == { name1 => value1, name2 => value2 }
        end
      end

      context 'when `names` parameter is empty`' do
        let(:params) { { id: id, names: [] } }

        it { is_expected.to be_empty }
      end

      context 'when `names` parameter specifies attributes`' do
        let(:params) { { id: id, names: [name1] } }

        it 'should extract specified attributes' do
          expect(subject).to be == { name1 => value1 }
        end
      end

      context 'when `names` parameter specifies absent attributes`' do
        let(:params) { { id: id, names: %w(absent) } }

        it { is_expected.to be_empty }
      end
    end
  end
end
