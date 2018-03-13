# frozen_string_literal: true

# Файл тестирования модели `CaseCore::Models::ProcessingStatus` статусов
# обработки сообщений STOMP

RSpec.describe CaseCore::Models::ProcessingStatus do
  describe 'the model' do
    subject { described_class }

    it { is_expected.to respond_to(:create) }
  end

  describe 'create' do
    subject(:result) { described_class.create(params) }

    let(:params) { attributes_for(:processing_status) }

    describe 'result' do
      subject { result }

      it { is_expected.to be_a(described_class) }
    end

    context 'when id is specified' do
      let(:params) { attributes_for(:processing_status, id: 'id') }

      it 'should raise Sequel::MassAssignmentRestriction' do
        expect { subject }.to raise_error(Sequel::MassAssignmentRestriction)
      end
    end

    context 'when message id is not nil but already exists in the table' do
      let(:params) { attributes_for(:processing_status, message_id: msg_id) }
      let(:msg_id) { processing_status.message_id }
      let!(:processing_status) { create(:processing_status) }

      it 'should raise Sequel::UniqueConstraintViolation' do
        expect { subject }.to raise_error(Sequel::UniqueConstraintViolation)
      end
    end

    context 'when status is not specified' do
      let(:params) { { headers: {}.pg_json } }

      it 'should raise Sequel::NotNullConstraintViolation' do
        expect { subject }.to raise_error(Sequel::NotNullConstraintViolation)
      end
    end

    context 'when status is nil' do
      let(:params) { attributes_for(:processing_status, status: nil) }

      it 'should raise Sequel::InvalidValue' do
        expect { subject }.to raise_error(Sequel::InvalidValue)
      end
    end

    context 'when status is not nil, `ok` nor `error`' do
      let(:params) { attributes_for(:processing_status, status: status) }
      let(:status) { 'not nil, `ok` nor `error`' }

      it 'should raise Sequel::DatabaseError' do
        expect { subject }.to raise_error(Sequel::DatabaseError)
      end
    end

    context 'when headers is not specified' do
      let(:params) { { status: :ok } }

      it 'should raise Sequel::NotNullConstraintViolation' do
        expect { subject }.to raise_error(Sequel::NotNullConstraintViolation)
      end
    end

    context 'when headers is nil' do
      let(:params) { attributes_for(:processing_status, headers: nil) }

      it 'should raise Sequel::InvalidValue' do
        expect { subject }.to raise_error(Sequel::InvalidValue)
      end
    end
  end

  describe 'instance of the model' do
    subject(:instance) { create(:processing_status) }

    methods = %i[
      id
      message_id
      status
      headers
      error_class
      error_text
      update
    ]
    it { is_expected.to respond_to(*methods) }
  end

  describe '#id' do
    subject(:result) { instance.id }

    describe 'result' do
      subject { result }

      let(:instance) { create(:processing_status) }

      it { is_expected.to be_an(Integer) }
    end
  end

  describe '#message_id' do
    subject(:result) { instance.message_id }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is present' do
        let(:instance) { create(:processing_status) }

        it { is_expected.to be_a(String) }
      end

      context 'when value of the corresponding field is absent' do
        let(:instance) { create(:processing_status, message_id: nil) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#status' do
    subject(:result) { instance.status }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is `ok`' do
        let(:instance) { create(:processing_status, status: 'ok') }

        it { is_expected.to be == 'ok' }
      end

      context 'when value of the corresponding field is `error`' do
        let(:instance) { create(:processing_status, status: 'error') }

        it { is_expected.to be == 'error' }
      end
    end
  end

  describe '#headers' do
    subject(:result) { instance.headers }

    describe 'result' do
      subject { result }

      let(:instance) { create(:processing_status) }

      it { is_expected.to be_a(Sequel::Postgres::JSONBHash) }
    end
  end

  describe '#error_class' do
    subject(:result) { instance.error_class }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is present' do
        let(:instance) { create(:processing_status, error_class: 'Error') }

        it { is_expected.to be_a(String) }
      end

      context 'when value of the corresponding field is absent' do
        let(:instance) { create(:processing_status, error_class: nil) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#error_text' do
    subject(:result) { instance.error_text }

    describe 'result' do
      subject { result }

      context 'when value of the corresponding field is present' do
        let(:instance) { create(:processing_status, error_text: 'text') }

        it { is_expected.to be_a(String) }
      end

      context 'when value of the corresponding field is absent' do
        let(:instance) { create(:processing_status, error_text: nil) }

        it { is_expected.to be_nil }
      end
    end
  end

  describe '#update' do
    subject(:result) { instance.update(params) }

    let(:instance) { create(:processing_status) }

    context 'when id is specified' do
      let(:params) { { id: 'id' } }

      it 'should raise Sequel::MassAssignmentRestriction' do
        expect { subject }.to raise_error(Sequel::MassAssignmentRestriction)
      end
    end

    context 'when message id is specified, not nil and exists in the table' do
      let(:params) { { message_id: message_id } }
      let(:message_id) { processing_status.message_id }
      let!(:processing_status) { create(:processing_status) }

      it 'should raise Sequel::UniqueConstraintViolation' do
        expect { subject }.to raise_error(Sequel::UniqueConstraintViolation)
      end
    end

    context 'when status is specified and nil' do
      let(:params) { { status: nil } }

      it 'should raise Sequel::InvalidValue' do
        expect { subject }.to raise_error(Sequel::InvalidValue)
      end
    end

    context 'when status is specified and not nil, `ok` nor `error`' do
      let(:params) { { status: status } }
      let(:status) { 'not nil, `ok` nor `error`' }

      it 'should raise Sequel::DatabaseError' do
        expect { subject }.to raise_error(Sequel::DatabaseError)
      end
    end

    context 'when headers is specified and nil' do
      let(:params) { { headers: nil } }

      it 'should raise Sequel::InvalidValue' do
        expect { subject }.to raise_error(Sequel::InvalidValue)
      end
    end
  end
end
