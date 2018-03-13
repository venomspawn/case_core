# frozen_string_literal: true

# Файл тестирования модуля `CaseCore::Helpers::SafeCall`, подключаемого для
# получения поддержки безопасного вызова методов

require "#{$lib}/helpers/safe_call"

RSpec.describe CaseCore::Helpers::SafeCall do
  let(:instance) { Object.new.extend described_class }

  describe 'instance' do
    subject { instance }

    it 'should have private method `safe_call`' do
      expect(subject.private_methods(true).include?(:safe_call)).to be_truthy
    end
  end

  describe '#safe_call' do
    subject(:result) { instance.send(:safe_call, obj, name, *args) }

    let(:obj) { Object.new }
    let(:name) { :respond_to? }
    let(:args) { %w[respond_to?] }

    it 'should call the method of the object with provided arguments' do
      expect(obj).to receive(name).with(*args)
      subject
    end

    describe 'result' do
      subject { result }

      context 'when no errors appear' do
        it { is_expected.to be_an(Array) }

        describe 'size' do
          subject { result.size }

          it { is_expected.to be == 2 }
        end

        describe 'first element' do
          subject { result.first }

          it 'should be equal to return value of the called method' do
            expect(subject).to be == obj.send(name, *args)
          end
        end

        describe 'second element' do
          subject { result.last }

          it { is_expected.to be_nil }
        end
      end

      context 'when an error appear during call' do
        before { allow(obj).to receive(name).and_raise }

        let(:obj) { double }
        let(:name) { :will_raise }

        it { is_expected.to be_an(Array) }

        describe 'size' do
          subject { result.size }

          it { is_expected.to be == 2 }
        end

        describe 'first element' do
          subject { result.first }

          it { is_expected.to be_nil }
        end

        describe 'second element' do
          subject { result.last }

          it { is_expected.to be_an(Exception) }
        end
      end

      context 'when the method doesn\'t exist' do
        let(:obj) { '123' }
        let(:name) { :doesnt_exist }

        it { is_expected.to be_an(Array) }

        describe 'size' do
          subject { result.size }

          it { is_expected.to be == 2 }
        end

        describe 'first element' do
          subject { result.first }

          it { is_expected.to be_nil }
        end

        describe 'second element' do
          subject { result.last }

          it { is_expected.to be_an(NoMethodError) }
        end
      end

      context 'when number of the arguments is wrong' do
        let(:obj) { '123' }
        let(:name) { :to_s }
        let(:args) { [123] }

        it { is_expected.to be_an(Array) }

        describe 'size' do
          subject { result.size }

          it { is_expected.to be == 2 }
        end

        describe 'first element' do
          subject { result.first }

          it { is_expected.to be_nil }
        end

        describe 'second element' do
          subject { result.last }

          it { is_expected.to be_an(ArgumentError) }
        end
      end
    end
  end
end
