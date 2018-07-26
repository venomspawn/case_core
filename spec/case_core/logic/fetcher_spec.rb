# frozen_string_literal: true

# Тестирование класса `CaseCore::Logic::Fetcher` загрузчика библиотек с
# бизнес-логикой с сервера библиотек

RSpec.describe CaseCore::Logic::Fetcher do
  describe 'the class' do
    subject { described_class }

    it { is_expected.to respond_to(:settings, :configure, :fetch) }
  end

  describe '.settings' do
    subject(:result) { described_class.settings }

    describe 'result' do
      subject { result }

      methods = %i[
        gem_server_host gem_server_host=
        gem_server_port gem_server_port=
        logic_dir logic_dir=
        set
      ]
      it { is_expected.to respond_to(*methods) }
      it { is_expected.to be_a(CaseCore::Settings::Mixin) }
    end
  end

  describe '.configure' do
    it 'should yield settings' do
      expect { |b| described_class.configure(&b) }
        .to yield_with_args(described_class.settings)
    end
  end

  describe '.fetch' do
    include described_class::Requests::LatestVersion::SpecHelper
    include described_class::SpecHelper

    before { described_class.settings.set :logic_dir, dir }

    subject(:result) { described_class.fetch(name, version) }

    let(:dir) { "#{CaseCore.root}/spec/fixtures/logic" }

    describe 'result' do
      context 'when name is empty' do
        before do
          stub_request(:get, /spec/)
            .to_return(body: spec_body, status: spec_status)
          stub_request(:get, /gems/)
            .to_return(body: gem1_body, status: gem1_status)
            .to_return(body: gem2_body, status: gem2_status)
        end

        after do
          FileUtils.rm_rf("#{dir}/#{gem1_name}-#{gem1_version}")
          FileUtils.rm_rf("#{dir}/#{gem2_name}-#{gem2_version}")
        end

        let(:name) { nil }
        let(:version) { nil }
        let(:spec_body) { create_spec_body(gem1_spec, gem2_spec) }
        let(:gem1_spec) { [gem1_name, gem1_version] }
        let(:gem2_spec) { [gem2_name, gem2_version] }
        let(:spec_status) { 200 }
        let(:gem1_body) { create_gem_body(gem1_name, gem1_version) }
        let(:gem2_body) { create_gem_body(gem2_name, gem2_version) }
        let(:gem1_status) { 200 }
        let(:gem2_status) { 200 }
        let(:gem1_name) { 'test1_case' }
        let(:gem2_name) { 'test2_case' }
        let(:gem1_version) { '0.0.1' }
        let(:gem2_version) { '0.0.1' }

        context 'when there is nothing to install' do
          let(:spec_body) { create_spec_body }

          it { is_expected.to be_truthy }
        end

        context 'when there is something to install' do
          context 'when an error happens during install of a gem' do
            let(:gem2_status) { 404 }

            it { is_expected.to be_falsey }
          end

          context 'when no error happens during install of every gem' do
            it { is_expected.to be_truthy }
          end
        end
      end

      context 'when name is not empty' do
        let(:name) { 'test' }

        context 'when version is specified during initialize' do
          before do
            stub_request(:get, /gem/)
              .to_return(body: gem_body, status: gem_status)
          end

          after { FileUtils.rm_rf("#{dir}/#{name}-#{version}") }

          let(:gem_body) { create_gem_body(name, version) }
          let(:gem_status) { 200 }
          let(:version) { '0.0.1' }

          context 'when gem body can\'t be fetched' do
            let(:gem_status) { 404 }

            it { is_expected.to be_falsey }
          end

          context 'when gem file can\'t be read by TAR reader' do
            before { allow(Gem::Package::TarReader).to receive(:new).and_raise }

            it { is_expected.to be_falsey }
          end

          context 'when gem file doesn\'t contain `data.tar.gz` file' do
            let(:gem_body) { create_gem_body_without_data_tar_gz }

            it { is_expected.to be_falsey }
          end

          context 'when `data.tar.gz` file is not of Gzip format' do
            let(:gem_body) { create_gem_body_with_bad_data_tar_gz }

            it { is_expected.to be_falsey }
          end

          context 'when no errors appear' do
            it { is_expected.to be_truthy }
          end
        end

        context 'when version is not specified during initialize or empty' do
          before do
            stub_request(:get, /spec/)
              .to_return(body: spec_body, status: spec_status)
            stub_request(:get, /gems/)
              .to_return(body: gem_body, status: gem_status)
          end

          after { FileUtils.rm_rf("#{dir}/#{name}-#{latest_version}") }

          let(:version) { '' }
          let(:latest_version) { '0.0.1' }
          let(:spec_body) { create_spec_body([name, latest_version]) }
          let(:spec_status) { 200 }
          let(:gem_body) { create_gem_body(name, latest_version) }
          let(:gem_status) { 200 }

          context 'when last version can\'t be fetched' do
            let(:spec_status) { 404 }

            it { is_expected.to be_falsey }
          end

          context 'when gem body can\'t be fetched' do
            let(:gem_status) { 404 }

            it { is_expected.to be_falsey }
          end

          context 'when gem file can\'t be read by TAR reader' do
            before do
              allow(Gem::Package::TarReader).to receive(:new).and_raise
            end

            it { is_expected.to be_falsey }
          end

          context 'when gem file doesn\'t contain `data.tar.gz` file' do
            let(:gem_body) { create_gem_body_without_data_tar_gz }

            it { is_expected.to be_falsey }
          end

          context 'when `data.tar.gz` file is not of Gzip format' do
            let(:gem_body) { create_gem_body_with_bad_data_tar_gz }

            it { is_expected.to be_falsey }
          end

          context 'when no errors appear' do
            it { is_expected.to be_truthy }
          end
        end
      end
    end

    context 'when name is empty' do
      before do
        stub_request(:get, /spec/)
          .to_return(body: spec_body, status: spec_status)
        stub_request(:get, /gems/)
          .to_return(body: gem1_body, status: gem1_status)
          .to_return(body: gem2_body, status: gem2_status)
      end

      after do
        FileUtils.rm_rf("#{dir}/#{gem1_name}-#{gem1_version}")
        FileUtils.rm_rf("#{dir}/#{gem2_name}-#{gem2_version}")
      end

      let(:name) { nil }
      let(:version) { nil }
      let(:spec_body) { create_spec_body(gem1_spec, gem2_spec) }
      let(:gem1_spec) { [gem1_name, gem1_version] }
      let(:gem2_spec) { [gem2_name, gem2_version] }
      let(:spec_status) { 200 }
      let(:gem1_body) { create_gem_body(gem1_name, gem1_version) }
      let(:gem2_body) { create_gem_body(gem2_name, gem2_version) }
      let(:gem1_status) { 200 }
      let(:gem2_status) { 200 }
      let(:gem1_name) { 'test1_case' }
      let(:gem2_name) { 'test2_case' }
      let(:gem1_version) { '0.0.1' }
      let(:gem2_version) { '0.0.1' }

      context 'when there appears a new gem' do
        it 'should install it' do
          subject
          expect(File.exist?("#{dir}/#{gem1_name}-#{gem1_version}"))
            .to be_truthy
        end

        context 'when server provides not one version of the gem' do
          let(:gem2_name) { gem1_name }
          let(:gem2_version) { gem1_version.succ }

          it 'should install last version' do
            subject
            expect(File.exist?("#{dir}/#{gem2_name}-#{gem2_version}"))
              .to be_truthy
          end
        end
      end

      context 'when there appears a new version of already installed gem' do
        before { FileUtils.mkdir(obsolete_gem_dir) }
        after { FileUtils.rm_rf(obsolete_gem_dir) }

        let(:obsolete_gem_dir) { "#{dir}/#{gem1_name}-#{obsolete_version}" }
        let(:obsolete_version) { '0.0.1' }
        let(:gem1_version) { obsolete_version.succ }
        let(:gem2_name) { gem1_name }
        let(:gem2_version) { gem1_version.succ }

        it 'should install last version of the gem' do
          subject
          expect(File.exist?("#{dir}/#{gem1_name}-#{gem2_version}"))
            .to be_truthy
        end

        it 'should keep obsolete version of the gem' do
          subject
          expect(File.exist?(obsolete_gem_dir)).to be_truthy
        end
      end

      context 'when there is no information about updates' do
        let(:spec_body) { create_spec_body }

        it 'shouldn\'t download any gems' do
          expect(WebMock).not_to have_requested(:get, /spec/)
          subject
        end
      end
    end

    context 'when name is not empty' do
      let(:name) { 'test' }

      context 'when version is specified during initialize' do
        before do
          stub_request(:get, /gem/)
            .to_return(body: gem_body, status: gem_status)
        end

        after { FileUtils.rm_rf("#{dir}/#{name}-#{version}") }

        let(:lib_file) { "#{dir}/#{name}-#{version}/lib/test.rb" }
        let(:spec_file) { "#{dir}/#{name}-#{version}/spec/test.rb" }
        let(:gem_body) { create_gem_body(name, version) }
        let(:gem_status) { 200 }
        let(:version) { '0.0.1' }

        context 'when gem body can\'t be fetched' do
          let(:gem_status) { 404 }

          it 'shouldn\'t extract logic files' do
            expect { subject }.not_to extract_logic_file(lib_file)
          end
        end

        context 'when gem file can\'t be read by TAR reader' do
          before { allow(Gem::Package::TarReader).to receive(:new).and_raise }

          it 'shouldn\'t extract logic files' do
            expect { subject }.not_to extract_logic_file(lib_file)
          end
        end

        context 'when gem file doesn\'t contain `data.tar.gz` file' do
          let(:gem_body) { create_gem_body_without_data_tar_gz }

          it 'shouldn\'t extract logic files' do
            expect { subject }.not_to extract_logic_file(lib_file)
          end
        end

        context 'when `data.tar.gz` file is not of Gzip format' do
          let(:gem_body) { create_gem_body_with_bad_data_tar_gz }

          it 'shouldn\'t extract logic files' do
            expect { subject }.not_to extract_logic_file(lib_file)
          end
        end

        context 'when no errors appear' do
          it 'shouldn extract logic files' do
            expect { subject }.to extract_logic_file(lib_file)
          end

          it 'shouldn\'t extract files with tests' do
            expect { subject }.not_to extract_logic_file(spec_file)
          end
        end
      end

      context 'when version is not specified during initialize or empty' do
        before do
          stub_request(:get, /spec/)
            .to_return(body: spec_body, status: spec_status)
          stub_request(:get, /gems/)
            .to_return(body: gem_body, status: gem_status)
        end

        after { FileUtils.rm_rf("#{dir}/#{name}-#{latest_version}") }

        let(:version) { '' }
        let(:latest_version) { '0.0.1' }
        let(:spec_body) { create_spec_body([name, latest_version]) }
        let(:spec_status) { 200 }
        let(:gem_body) { create_gem_body(name, latest_version) }
        let(:gem_status) { 200 }
        let(:lib_file) { "#{dir}/#{name}-#{latest_version}/lib/test.rb" }
        let(:spec_file) { "#{dir}/#{name}-#{latest_version}/spec/test.rb" }

        context 'when last version can\'t be fetched' do
          let(:spec_status) { 404 }

          it 'shouldn\'t extract logic files' do
            expect { subject }.not_to extract_logic_file(lib_file)
          end
        end

        context 'when gem body can\'t be fetched' do
          let(:gem_status) { 404 }

          it 'shouldn\'t extract logic files' do
            expect { subject }.not_to extract_logic_file(lib_file)
          end
        end

        context 'when gem file can\'t be read by TAR reader' do
          before { allow(Gem::Package::TarReader).to receive(:new).and_raise }

          it 'shouldn\'t extract logic files' do
            expect { subject }.not_to extract_logic_file(lib_file)
          end
        end

        context 'when gem file doesn\'t contain `data.tar.gz` file' do
          let(:gem_body) { create_gem_body_without_data_tar_gz }

          it 'shouldn\'t extract logic files' do
            expect { subject }.not_to extract_logic_file(lib_file)
          end
        end

        context 'when `data.tar.gz` file is not of Gzip format' do
          let(:gem_body) { create_gem_body_with_bad_data_tar_gz }

          it 'shouldn\'t extract logic files' do
            expect { subject }.not_to extract_logic_file(lib_file)
          end
        end

        context 'when no errors appear' do
          it 'should extract logic files' do
            expect { subject }.to extract_logic_file(lib_file)
          end

          it 'shouldn\'t extract files with tests' do
            expect { subject }.not_to extract_logic_file(spec_file)
          end
        end
      end
    end
  end

  describe 'instance' do
    subject { described_class.new(name) }

    let(:name) { 'abc' }

    it { is_expected.to respond_to(:fetch) }
  end

  describe '#fetch' do
    include described_class::Requests::LatestVersion::SpecHelper
    include described_class::SpecHelper

    before { described_class.settings.set :logic_dir, dir }

    subject(:result) { instance.fetch }

    let(:instance) { described_class.new(name, version) }
    let(:dir) { "#{CaseCore.root}/spec/fixtures/logic" }
    let(:name) { 'test' }
    let(:version) { '0.0.1' }

    describe 'result' do
      context 'when version is specified during initialize' do
        before do
          stub_request(:get, /gem/)
            .to_return(body: gem_body, status: gem_status)
        end

        after { FileUtils.rm_rf("#{dir}/#{name}-#{version}") }

        let(:gem_body) { create_gem_body(name, version) }
        let(:gem_status) { 200 }

        context 'when gem body can\'t be fetched' do
          let(:gem_status) { 404 }

          it { is_expected.to be_falsey }
        end

        context 'when gem file can\'t be read by TAR reader' do
          before { allow(Gem::Package::TarReader).to receive(:new).and_raise }

          it { is_expected.to be_falsey }
        end

        context 'when gem file doesn\'t contain `data.tar.gz` file' do
          let(:gem_body) { create_gem_body_without_data_tar_gz }

          it { is_expected.to be_falsey }
        end

        context 'when `data.tar.gz` file is not of Gzip format' do
          let(:gem_body) { create_gem_body_with_bad_data_tar_gz }

          it { is_expected.to be_falsey }
        end

        context 'when no errors appear' do
          it { is_expected.to be_truthy }
        end
      end

      context 'when version is not specified during initialize or empty' do
        before do
          stub_request(:get, /spec/)
            .to_return(body: spec_body, status: spec_status)
          stub_request(:get, /gems/)
            .to_return(body: gem_body, status: gem_status)
        end

        after { FileUtils.rm_rf("#{dir}/#{name}-#{latest_version}") }

        let(:version) { '' }
        let(:latest_version) { '0.0.1' }
        let(:spec_body) { create_spec_body([name, latest_version]) }
        let(:spec_status) { 200 }
        let(:gem_body) { create_gem_body(name, latest_version) }
        let(:gem_status) { 200 }

        context 'when last version can\'t be fetched' do
          let(:spec_status) { 404 }

          it { is_expected.to be_falsey }
        end

        context 'when gem body can\'t be fetched' do
          let(:gem_status) { 404 }

          it { is_expected.to be_falsey }
        end

        context 'when gem file can\'t be read by TAR reader' do
          before { allow(Gem::Package::TarReader).to receive(:new).and_raise }

          it { is_expected.to be_falsey }
        end

        context 'when gem file doesn\'t contain `data.tar.gz` file' do
          let(:gem_body) { create_gem_body_without_data_tar_gz }

          it { is_expected.to be_falsey }
        end

        context 'when `data.tar.gz` file is not of Gzip format' do
          let(:gem_body) { create_gem_body_with_bad_data_tar_gz }

          it { is_expected.to be_falsey }
        end

        context 'when no errors appear' do
          it { is_expected.to be_truthy }
        end
      end
    end

    context 'when version is specified during initialize' do
      before do
        stub_request(:get, /gem/)
          .to_return(body: gem_body, status: gem_status)
      end

      after { FileUtils.rm_rf("#{dir}/#{name}-#{version}") }

      let(:lib_file) { "#{dir}/#{name}-#{version}/lib/test.rb" }
      let(:spec_file) { "#{dir}/#{name}-#{version}/spec/test.rb" }
      let(:gem_body) { create_gem_body(name, version) }
      let(:gem_status) { 200 }

      context 'when gem body can\'t be fetched' do
        let(:gem_status) { 404 }

        it 'shouldn\'t extract logic files' do
          expect { subject }.not_to extract_logic_file(lib_file)
        end
      end

      context 'when gem file can\'t be read by TAR reader' do
        before { allow(Gem::Package::TarReader).to receive(:new).and_raise }

        it 'shouldn\'t extract logic files' do
          expect { subject }.not_to extract_logic_file(lib_file)
        end
      end

      context 'when gem file doesn\'t contain `data.tar.gz` file' do
        let(:gem_body) { create_gem_body_without_data_tar_gz }

        it 'shouldn\'t extract logic files' do
          expect { subject }.not_to extract_logic_file(lib_file)
        end
      end

      context 'when `data.tar.gz` file is not of Gzip format' do
        let(:gem_body) { create_gem_body_with_bad_data_tar_gz }

        it 'shouldn\'t extract logic files' do
          expect { subject }.not_to extract_logic_file(lib_file)
        end
      end

      context 'when no errors appear' do
        it 'shouldn\'t extract logic files' do
          expect { subject }.to extract_logic_file(lib_file)
        end

        it 'shouldn\'t extract files with tests' do
          expect { subject }.not_to extract_logic_file(spec_file)
        end
      end
    end

    context 'when version is not specified during initialize or empty' do
      before do
        stub_request(:get, /spec/)
          .to_return(body: spec_body, status: spec_status)
        stub_request(:get, /gems/)
          .to_return(body: gem_body, status: gem_status)
      end

      after { FileUtils.rm_rf("#{dir}/#{name}-#{latest_version}") }

      let(:version) { '' }
      let(:latest_version) { '0.0.1' }
      let(:spec_body) { create_spec_body([name, latest_version]) }
      let(:spec_status) { 200 }
      let(:gem_body) { create_gem_body(name, latest_version) }
      let(:gem_status) { 200 }
      let(:lib_file) { "#{dir}/#{name}-#{latest_version}/lib/test.rb" }
      let(:spec_file) { "#{dir}/#{name}-#{latest_version}/spec/test.rb" }

      context 'when last version can\'t be fetched' do
        let(:spec_status) { 404 }

        it 'shouldn\'t extract logic files' do
          expect { subject }.not_to extract_logic_file(lib_file)
        end
      end

      context 'when gem body can\'t be fetched' do
        let(:gem_status) { 404 }

        it 'shouldn\'t extract logic files' do
          expect { subject }.not_to extract_logic_file(lib_file)
        end
      end

      context 'when gem file can\'t be read by TAR reader' do
        before { allow(Gem::Package::TarReader).to receive(:new).and_raise }

        it 'shouldn\'t extract logic files' do
          expect { subject }.not_to extract_logic_file(lib_file)
        end
      end

      context 'when gem file doesn\'t contain `data.tar.gz` file' do
        let(:gem_body) { create_gem_body_without_data_tar_gz }

        it 'shouldn\'t extract logic files' do
          expect { subject }.not_to extract_logic_file(lib_file)
        end
      end

      context 'when `data.tar.gz` file is not of Gzip format' do
        let(:gem_body) { create_gem_body_with_bad_data_tar_gz }

        it 'shouldn\'t extract logic files' do
          expect { subject }.not_to extract_logic_file(lib_file)
        end
      end

      context 'when no errors appear' do
        it 'should extract logic files' do
          expect { subject }.to extract_logic_file(lib_file)
        end

        it 'shouldn\'t extract files with tests' do
          expect { subject }.not_to extract_logic_file(spec_file)
        end
      end
    end
  end
end
