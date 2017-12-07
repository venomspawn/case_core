# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Тесты класса `CaseCore::Censorship::Filter` объектов, фильтрующих ключи
# ассоциативных массиво и строки
#

RSpec.describe CaseCore::Censorship::Filter do
  subject { described_class }

  it { is_expected.to respond_to(:process) }

  describe '.process' do
    subject(:result) { described_class.process(obj) }

    let(:settings) { described_class.settings }

    context 'when argument is of Hash type' do
      let(:obj) { { a: :b } }

      describe 'result' do
        subject { result }

        it { is_expected.to be_a(Hash) }

        it 'should be a new Hash' do
          expect(result.object_id).not_to be == obj.object_id
        end

        it 'should have the same keys' do
          expect(result.keys).to be == obj.keys
        end

        context 'when argument keys are censored' do
          before { settings.filter :password }

          let(:obj) { { password: 'very secret' } }

          it 'should censor the value' do
            expect(result[:password]).to be == settings.censored_message
          end
        end
      end

      context 'when argument has values of Hash type' do
        let(:obj) { { a: { b: :c } } }

        it 'should process the values' do
          expect(result[:a].object_id).not_to be == obj[:a].object_id
        end
      end

      context 'when argument has values of Array type' do
        let(:obj) { { a: [1, 2] } }

        it 'should process the values' do
          expect(result[:a].object_id).not_to be == obj[:a].object_id
        end
      end

      context 'when argument has values of String type' do
        let(:obj) { { a: long_string } }
        let(:long_string) { 'a' * more_than_limit }
        let(:more_than_limit) { settings.string_length_limit + 1 }

        it 'should process the values' do
          expect(result[:a].object_id).not_to be == obj[:a].object_id
        end
      end
    end

    context 'when argument is of Array type' do
      let(:obj) { [:a, :b] }

      describe 'result' do
        subject { result }

        it { is_expected.to be_an(Array) }

        it 'should be a new Array' do
          expect(result.object_id).not_to be == obj.object_id
        end

        it 'should have the same size' do
          expect(result.size).to be == obj.size
        end
      end

      context 'when argument has elements of Hash type' do
        let(:obj) { [b: :c] }

        it 'should process the values' do
          expect(result.first.object_id).not_to be == obj.first.object_id
        end
      end

      context 'when argument has elements of Array type' do
        let(:obj) { [[1, 2]] }

        it 'should process the values' do
          expect(result.first.object_id).not_to be == obj.first.object_id
        end
      end

      context 'when argument has elements of String type' do
        let(:obj) { [long_string] }
        let(:long_string) { 'a' * more_than_limit }
        let(:more_than_limit) { settings.string_length_limit + 1 }

        it 'should process the values' do
          expect(result.first.object_id).not_to be == obj.first.object_id
        end
      end
    end

    context 'when argument is of String type' do
      let(:obj) { '' }

      describe 'result' do
        subject { result }

        it { is_expected.to be_a(String) }

        context 'when argument is not too big nor to be parsed' do
          it 'should be the same string' do
            expect(result.object_id).to be == obj.object_id
          end
        end

        context 'when argument is too big' do
          let(:obj) { 'a' * more_than_limit }
          let(:more_than_limit) { settings.string_length_limit + 1 }

          it { is_expected.to be == settings.too_long_message }
        end

        context 'when argument is to be parsed' do
          let(:obj) { structure.to_json }
          let(:structure) { { a: :b } }

          it 'should be equal to JSON-string of censored structure' do
            expect(subject).to be == described_class.process(structure).to_json
          end
        end
      end
    end

    context 'when argument is not of Hash, Array or String type' do
      let(:obj) { Object.new }

      describe 'result' do
        subject { result }

        it 'should be the same object' do
          expect(subject.object_id).to be == obj.object_id
        end
      end
    end
  end
end
