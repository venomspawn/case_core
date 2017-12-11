# encoding: utf-8

module CaseCore
  module Logic
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Вспомогательный модуль, подключаемый к тестам класса
    # {CaseCore::Logic::Fetcher}
    #
    module FetcherSpecHelper
      # Создаёт и возвращает тело файла библиотеки, которая содержит
      # единственный файл вида `lib/<name>.rb`, где `<name>` — предоставленное
      # название библиотеки. В файле определяется Ruby-модуль с названием,
      # совпадающим с названием библиотеки в ВерблюжьемРегистре. В этом
      # Ruby-модуле определяется единственная константа `VERSION` со значением,
      # которое равно строке с предоставленной версией.
      #
      # @param [String] name
      #   название библиотеки
      #
      # @param [String] version
      #   версия библиотеки
      #
      # @return [String]
      #   тело файла библиотеки
      #
      def create_gem_body(name, version)
        content = <<-CONTENT
          module #{name.camelize}
            VERSION = #{version}
          end
        CONTENT
        data_tar = create_tar("lib/#{name}.rb" => content)
        data_tar_gz = Zlib.gzip(data_tar)
        create_tar('data.tar.gz' => data_tar_gz)
      end

      # Создаёт и возвращает тело TAR-архива, в котором отсутствует файл
      # `data.tar.gz`
      #
      # @return [String]
      #   тело результирующего TAR-архива
      #
      def create_gem_body_without_data_tar_gz
        create_tar('without_data_tar_gz' => '')
      end

      # Создаёт и возвращает тело TAR-архива, в котором файла `data.tar.gz` не
      # представляет собой Gzip-архив
      #
      # @return [String]
      #   тело результирующего TAR-архива
      #
      def create_gem_body_with_bad_data_tar_gz
        create_tar('data.tar.gz' => '123')
      end

      private

      # Создаёт TAR-архив на основе информации предоставленного ассоциативного
      # массива, ключи которого являются именами файлов, а значения — телами
      # этих файлов, и возвращает тело созданного TAR-архива
      #
      # @param [Hash{String => String}] names_to_content
      #   предоставленный ассоциативный массив
      #
      # @return [String]
      #   тело созданного TAR-архива
      #
      def create_tar(names_to_content)
        stream = StringIO.new
        tar_writer = Gem::Package::TarWriter.new(stream)
        names_to_content.each do |(name, content)|
          tar_writer.add_file(name, 0444) { |io| io.write(content) }
        end
        stream.rewind
        stream.read
      end
    end
  end
end
