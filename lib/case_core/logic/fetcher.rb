# frozen_string_literal: true

require 'fileutils'
require 'rubygems/package'

require_relative 'fetcher/helpers'
require_relative 'fetcher/requests/gem'
require_relative 'fetcher/requests/latest_version'
require_relative 'fetcher/requests/latest_versions'

module CaseCore
  need 'settings/configurable'

  module Logic
    # Класс, предоставляющий функцию `fetch`, которая загружает и распаковывает
    # указанную или последнюю версию библиотеки с данным названием
    class Fetcher
      include Helpers
      extend  Settings::Configurable

      settings_names :gem_server_host, :gem_server_port, :gem_server_path
      settings_names :logic_dir

      # Загружает и распаковывает указанную или последнюю версию библиотеки с
      # данным названием. Возвращает, успешно ли прошёл процесс загрузки и
      # распаковки.
      # @param [#to_s] name
      #   название библиотеки
      # @param [#to_s] version
      #   версия библиотеки. Если значение пусто, то загружается последняя
      #   версия библиотеки.
      # @return [Boolean]
      #   успешно ли прошёл процесс загрузки и распаковки
      def self.fetch(name, version = nil)
        new(name, version).fetch
      end

      # Инициализирует объект класса
      # @param [#to_s] name
      #   название библиотеки
      # @param [#to_s] version
      #   версия библиотеки
      def initialize(name, version = nil)
        @name = name.to_s
        @version = version.to_s
      end

      # Загружает и распаковывает указанную или последнюю версию библиотеки с
      # данным названием. Возвращает, успешно ли прошёл процесс загрузки и
      # распаковки.
      # @return [Boolean]
      #   успешно ли прошёл процесс загрузки и распаковки
      def fetch
        log_fetch_start(name, @version, binding)
        extract_entries
        log_fetch_finish(name, version, binding)
        true
      rescue StandardError => e
        log_fetch_error(e, binding)
        false
      end

      private

      # Название библиотеки
      # @return [#to_s]
      #   название библиотеки
      attr_reader :name

      # Возвращает версию библиотеки, при этом если версия была предоставлена,
      # то возвращает предоставленное значение, если же версия не была
      # предоставлена, то осуществляет запрос на сервер библиотек для получения
      # последней версии
      # @return [String]
      #   версия библиотеки
      # @raise [RuntimeError]
      #   если во время получения последней версии библиотеки произошла ошибка
      def version
        return @version unless @version.empty?
        @version = Requests::LatestVersion
                   .latest_version(name)
                   .tap(&method(:check_version!))
                   .tap { |result| log_last_version(name, result, binding) }
      end

      # Возвращает путь к директории с библиотеками из настроек класса
      # {CaseCore::Logic::Loader}
      # @return [String]
      #   путь к директории с библиотеками
      def gems_dir
        Fetcher.settings.logic_dir
      end

      # Возвращает путь к директории с библиотекой
      # @return [String]
      #   путь к директории с библиотекой
      def gem_dir
        @gem_dir ||= "#{gems_dir}/#{name}-#{version}"
      end

      # Возвращает тело файла с библиотекой, загруженного с сервера библиотек
      # @return [String]
      #   тело файла с библиотекой
      # @raise [RuntimeError]
      #   если во время загрузки файла произошла ошибка
      def gem
        Requests::Gem.gem(name, version).tap(&method(:check_gem!))
      end

      # Название архива, хранящего файлы библиотеки
      PACKED_DATA_FILENAME = 'data.tar.gz'

      # Возвращает тело архива, хранящего файлы библиотеки
      # @return [String]
      #   тело архива
      # @raise [RuntimeError]
      #   если архив не найден в теле файла с библиотекой
      def packed_data
        gem_stream = StringIO.new(gem)
        tar_reader = Gem::Package::TarReader.new(gem_stream)
        result = tar_reader.seek(PACKED_DATA_FILENAME, &:read)
        result.tap(&method(:check_packed_data_entry!))
      end

      # Возвращает поток с распакованным телом архива, хранящего файлы
      # библиотеки
      # @return [Gem::Package::TarReader]
      #   поток с распакованным телом архива
      def data_reader
        data = Zlib.gunzip(packed_data)
        data_stream = StringIO.new(data)
        Gem::Package::TarReader.new(data_stream)
      end

      # Названия директорий, не подлежащих распаковке
      BANNED_DIRS = %w[test spec].freeze

      # Проверяет, нужно ли распаковать содержимое потока
      # @param [Gem::Package::TarReader::Entry] entry
      #   поток в формате TAR
      # @return [Boolean]
      #   нужно ли распаковать содержимое потока
      def ban_entry?(entry)
        entry.full_name.start_with?(*BANNED_DIRS)
      end

      # Распаковывает содержимое потока
      # @param [Gem::Package::TarReader::Entry] entry
      #   поток в формате TAR
      def extract_entry(entry)
        if entry.file?
          extract_file(entry)
        elsif entry.directory?
          extract_directory(entry)
        end
      end

      # Создаёт директорию
      # @param [Gem::Package::TarReader::Entry] entry
      #   поток в формате TAR
      def extract_drectory(entry)
        entry_filepath = "#{gem_dir}/#{entry.full_name}"
        FileUtils.mkdir_p(entry_filepath)
      end

      # Распаковывает содержимое потока в файл
      # @param [Gem::Package::TarReader::Entry] entry
      #   поток в формате TAR
      def extract_file(entry)
        entry_filepath = "#{gem_dir}/#{entry.full_name}"
        entry_dir = File.dirname(entry_filepath)
        FileUtils.mkdir_p(entry_dir)
        IO.binwrite(entry_filepath, entry.read)
        log_extract_entry(entry_filepath, binding)
      end

      # Распаковывает содержимое архива с файлами библиотеки в директорию с
      # библиотекой
      def extract_entries
        data_reader.each_entry do |entry|
          extract_entry(entry) unless ban_entry?(entry)
        end
      end
    end
  end
end
