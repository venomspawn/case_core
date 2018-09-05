# frozen_string_literal: true

# Тестирование класса объектов, удаляющих записи файлов, на которые не
# ссылается ни один документ

CaseCore.need 'dfc/sweep'

RSpec.describe CaseCore::DFC::Sweep do
  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:invoke) }
  end

  describe '.invoke' do
    subject { described_class.invoke(death_age) }

    let(:death_age) { 10 }
    let(:files) { CaseCore::Models::File }
    let!(:scan) { FactoryBot.create(:scan) }

    context 'when there are no documentless files' do
      it 'shouldn\'t delete any file' do
        expect { subject }.not_to change { files.count }
      end
    end

    context 'when there are scanless files' do
      let!(:young_file) { FactoryBot.create(:file) }
      let!(:old_file) { FactoryBot.create(:file, created_at: old) }
      let(:old) { Time.now - death_age - 1 }

      it 'shouldn\'t delete young scanless files' do
        expect { subject }
          .not_to change { files.where(id: young_file.id).count }
      end

      it 'should delete old scanless files' do
        expect { subject }
          .to change { files.where(id: old_file.id).count }
          .to(0)
      end
    end
  end
end
