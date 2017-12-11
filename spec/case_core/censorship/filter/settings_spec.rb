# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл тестирования класса `CaseCore::Censorship::Filter::Settings` настроек
# фильтрации ключей ассоциативных массивов и строк
#

RSpec.describe CaseCore::Censorship::Filter::Settings do
  subject(:instance) { described_class.new }

  methods = %i(
    censored_message    censored_message=
    too_long_message    too_long_message=
    string_length_limit string_length_limit=
    filters             filters=
    filter
    set
  )

  it { is_expected.to respond_to(*methods) }

  describe '#censored_message' do
    subject(:result) { instance.censored_message }

    describe 'result' do
      subject { result }

      it { is_expected.to be_an(Object) }

      let(:value) { Object.new }

      it 'should return what was set by method `censored_message=`' do
        instance.censored_message = value
        expect(subject).to be == value
      end
    end
  end

  describe '#censored_message=' do
    subject(:result) { instance.censored_message = value }

    let(:value) { Object.new }

    describe 'result' do
      subject { result }

      it 'should be equal to argument' do
        expect(subject).to be == value
      end
    end

    it 'should change return value of `censored_message` method' do
      expect { subject }.to change { instance.censored_message }.to(value)
    end
  end

  describe '#too_long_message' do
    subject(:result) { instance.too_long_message }

    describe 'result' do
      subject { result }

      it { is_expected.to be_an(Object) }

      let(:value) { Object.new }

      it 'should return what was set by method `too_long_message=`' do
        instance.too_long_message = value
        expect(subject).to be == value
      end
    end
  end

  describe '#too_long_message=' do
    subject(:result) { instance.too_long_message = value }

    let(:value) { Object.new }

    describe 'result' do
      subject { result }

      it 'should be equal to argument' do
        expect(subject).to be == value
      end
    end

    it 'should change return value of `too_long_message` method' do
      expect { subject }.to change { instance.too_long_message }.to(value)
    end
  end

  describe '#string_length_limit' do
    subject(:result) { instance.string_length_limit }

    describe 'result' do
      subject { result }

      context 'when limit is present' do
        before { instance.string_length_limit = limit }

        let(:limit) { 10 }

        it 'should be equal to the limit' do
          expect(subject).to be == limit
        end
      end

      context 'when limit is absent' do
        it { is_expected.to be_nil }
      end
    end
  end

  describe '#string_length_limit=' do
    before { instance.string_length_limit = 1 }

    subject { instance.string_length_limit = limit }

    context 'when argument is nil' do
      let(:limit) { nil }

      it 'should change result of `string_length_limit` method to nil' do
        expect { subject }.to change { instance.string_length_limit }.to(nil)
      end
    end

    context 'when argument is a numeric no less than 1' do
      let(:limit) { 2.5 }

      it 'should change result of `string_length_limit` method to natural' do
        expect { subject }.to change { instance.string_length_limit }.to(2)
      end
    end

    context 'when argument is a numeric less than 1' do
      let(:limit) { 0.5 }

      it 'should change result of `string_length_limit` method to nil' do
        expect { subject }.to change { instance.string_length_limit }.to(nil)
      end
    end

    context 'when argument is not a numeric nor nil' do
      context 'when argument can be cast to a numeric via `to_s.to_i`' do
        context 'when the numeric is no less than 1' do
          let(:limit) { '2.5' }

          it 'should change result of `string_length_limit` method' do
            expect { subject }
              .to change { instance.string_length_limit }
              .to(2)
          end
        end

        context 'when the numeric is less than 1' do
          let(:limit) { '0.5' }

          it 'should change result of `string_length_limit` method to nil' do
            expect { subject }
              .to change { instance.string_length_limit }
              .to(nil)
          end
        end
      end

      context 'when argument can\'t be cast to a numeric' do
        let(:limit) { Object.new }

        it 'should change result of `string_length_limit` method to nil' do
          expect { subject }.to change { instance.string_length_limit }.to(nil)
        end
      end
    end
  end

  describe '#filters' do
    subject(:result) { instance.filters }

    describe 'result' do
      subject { result }

      it { is_expected.to be_an(Array) }

      context 'when it is not empty' do
        before { instance.filters = %w(abc def) }

        it { is_expected.to all(be_a(Symbol)) }
      end

      context 'when filters are set' do
        before { instance.filters = %w(abc def) }

        it 'should return new values' do
          expect(subject).to match_array %i(abc def)
        end
      end
    end
  end

  describe '#filters=' do
    subject { instance.filters = filters }

    let(:filters) { %w(abc def) }

    it 'should change return value of `filters` method' do
      expect { subject }.to change { instance.filters }.to(%i(abc def))
    end

    context 'when argument doesn\'t support `map` method' do
      let(:filters) { Object.new }

      it 'should raise NoMethodError' do
        expect { subject }.to raise_error(NoMethodError)
      end
    end

    context 'when elements of the argument don\'t support `to_sym` method' do
      let(:filters) { [Object.new] }

      it 'should raise NoMethodError' do
        expect { subject }.to raise_error(NoMethodError)
      end
    end
  end

  describe '#filter' do
    before { instance.filters = %i(abc) }

    subject { instance.filter(*args) }

    let(:args) { %w(def key) }

    it 'should add elements to return value of `filters` method' do
      expect { subject }.to change { instance.filters }.to(%i(abc def key))
    end

    context 'when arguments don\'t support `to_sym` method' do
      let(:args) { [Object.new] }

      it 'should raise NoMethodError' do
        expect { subject }.to raise_error(NoMethodError)
      end
    end
  end

  describe '#set' do
    subject { instance.set name, value }

    let(:name) { :censored_message }
    let(:value) { :value }

    it 'should change value of the corresponding property' do
      expect { subject }.to change { instance.censored_message }.to(value)
    end

    context 'when there is no property in the settings with the name' do
      let(:name) { 'won\'t be found' }

      it 'should raise NoMethodError' do
        expect { subject }.to raise_error(NoMethodError)
      end
    end
  end
end
