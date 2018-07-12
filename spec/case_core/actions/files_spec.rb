# frozen_string_literal: true

# Тестирование функций модуля `CaseCore::Actions::Files`

RSpec.describe CaseCore::Actions::Files do
  describe 'the module' do
    subject { described_class }

    it { is_expected.to respond_to(:create) }
  end

  describe '.create' do
    include described_class::Create::SpecHelper

    subject(:result) { described_class.create(content) }

    let(:content) { create(:string) }
    let(:file) { CaseCore::Models::File[subject[:id]] }

    it 'should create file record' do
      expect { subject }.to change { CaseCore::Models::File.count }.by(1)
    end

    it 'should set timestamp of created record to now' do
      expect(file.created_at).to be_within(1).of(Time.now)
    end

    describe 'result' do
      subject { result }

      it { is_expected.to match_json_schema(schema) }
    end

    context 'when `content` responds to #read' do
      let(:content) { StringIO.new(str) }
      let(:str) { create(:string) }

      it 'should call #read of `content`' do
        expect(content).to receive(:read)
        subject
      end

      it 'should use result of calling #read as the file content' do
        expect(file.content).to be == str
      end

      context 'when `content` responds to #rewind' do
        it 'should call #rewind of `content`' do
          expect(content).to receive(:rewind)
          subject
        end
      end
    end

    context 'when `content` does not respond to #read' do
      let(:content) { create(:string) }

      it 'should use `content` as the file content' do
        expect(file.content).to be == content
      end
    end
  end
end
