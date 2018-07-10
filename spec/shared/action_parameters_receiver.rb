# frozen_string_literal: true

# Общие тесты интерфейса передачи параметров действия

RSpec.shared_examples 'an action parameters receiver' do |args|
  context 'when `params` is of Hash type' do
    context 'when `params` is of wrong structure' do
      let(:params) { args[:wrong_structure] }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end
  end

  context 'when `params` is of String type' do
    context 'when `params` is a JSON-string' do
      let(:params) { Oj.dump(data) }

      context 'when `params` represents a map' do
        context 'when the map is of wrong structure' do
          let(:data) { args[:wrong_structure] }

          it 'should raise JSON::Schema::ValidationError' do
            expect { subject }.to raise_error(JSON::Schema::ValidationError)
          end
        end
      end

      context 'when `params` does not represent a map' do
        let(:data) { %w[not a map] }

        it 'should raise JSON::Schema::ValidationError' do
          expect { subject }.to raise_error(JSON::Schema::ValidationError)
        end
      end
    end

    context 'when `params` is not a JSON-string' do
      let(:params) { 'not a JSON-string' }

      it 'should raise Oj::ParseError' do
        expect { subject }.to raise_error(Oj::ParseError)
      end
    end
  end

  context 'when `params` is neither of Hash type nor of String type' do
    context 'when `params` responds to #read' do
      context 'when #read returns something convertable to a JSON-string' do
        let(:params) { StringIO.new(str) }
        let(:str) { Oj.dump(data) }

        context 'when that something represents a map' do
          context 'when the map is of wrong structure' do
            let(:data) { args[:wrong_structure] }

            it 'should raise JSON::Schema::ValidationError' do
              expect { subject }.to raise_error(JSON::Schema::ValidationError)
            end
          end
        end

        context 'when that something does not represent a map' do
          let(:data) { %w[not a map] }

          it 'should raise JSON::Schema::ValidationError' do
            expect { subject }.to raise_error(JSON::Schema::ValidationError)
          end
        end

        context 'when `params` also responds to #rewind' do
          let(:params) { StringIO.new(str) }
          let(:str) { Oj.dump(data) }
          let(:data) { args[:params] }

          it 'should call #rewind of `params`' do
            expect(params).to receive(:rewind)
            subject
          end
        end
      end

      context 'when #read doesn\'t return anything JSON-like' do
        let(:params) { Struct.new(:read).new('not JSON-like') }

        it 'should raise Oj::ParseError' do
          expect { subject }.to raise_error(Oj::ParseError)
        end
      end
    end

    context 'when `params` does not respond to #read' do
      let(:params) { %w[does not respond to #read] }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end
  end

  context 'when `rest` is of Hash type' do
    context 'when `rest` is of wrong structure' do
      let(:params) { {} }
      let(:rest) { args[:wrong_structure] }

      it 'should raise JSON::Schema::ValidationError' do
        expect { subject }.to raise_error(JSON::Schema::ValidationError)
      end
    end
  end

  context 'when `rest` is neither of Hash type nor of NilClass type' do
    let(:params) { {} }
    let(:rest) { 'neither of Hash type nor of NilClass type' }

    it 'should raise TypeError' do
      expect { subject }.to raise_error(TypeError)
    end
  end
end
