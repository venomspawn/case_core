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
    # библиотеки с бизнес-логикой
    class Fetcher
      include Helpers
      extend  Settings::Configurable

      settings_names :gem_server_host, :gem_server_port, :gem_server_path
      settings_names :logic_dir

      # В зависимости от предоставленных параметров выполняет следующие
      # действия.
      #
      # 1. Если параметр `name` принимает пустое значение, то с сервера
      #    библиотек загружаются недостающие библиотеки с бизнес-логикой
      #    последних версий. Поддерживаются только библиотеки, названия которых
      #    заканчиваются на стркоу {SUFFIX}.
      # 2. Если параметр `name` принимает непустое значение, то с сервера
      #    библиотек загружается библиотека с названием, равным значению
      #    параметра. При этом если значение параметра `version` пусто, то
      #    загружается последняя версия, а в противном случае — с указанной
      #    версией.
      #
      # Возвращает, успешно ли прошёл процесс загрузки и распаковки.
      # @param [#to_s] name
      #   название библиотеки. Если значение пусто, то с сервера библиотек
      #   загружаются недостающие библиотеки с бизнес-логикой последних версий.
      # @param [#to_s] version
      #   версия библиотеки. Если значение пусто, то загружается последняя
      #   версия библиотеки. Значение игнорируется, если значение параметра
      #   `name` пусто.
      # @return [Boolean]
      #   успешно ли прошёл процесс загрузки и распаковки
      def self.fetch(name = nil, version = nil)
        new(name, version).fetch
      end

      # Инициализирует объект класса
      # @param [#to_s] name
      #   название библиотеки. Если значение пусто, то с сервера библиотек
      #   загружаются недостающие библиотеки с бизнес-логикой последних версий.
      # @param [#to_s] version
      #   версия библиотеки. Если значение пусто, то загружается последняя
      #   версия библиотеки. Значение игнорируется, если значение параметра
      #   `name` пусто.
      def initialize(name = nil, version = nil)
        @name = name.to_s
        @version = version.to_s
      end

      # В зависимости от предоставленных параметров выполняет следующие
      # действия.
      #
      # 1. Если параметр `name` принимает пустое значение, то с сервера
      #    библиотек загружаются недостающие библиотеки с бизнес-логикой
      #    последних версий. Поддерживаются только библиотеки, названия которых
      #    заканчиваются на стркоу {SUFFIX}.
      # 2. Если параметр `name` принимает непустое значение, то с сервера
      #    библиотек загружается библиотека с названием, равным значению
      #    параметра. При этом если значение параметра `version` пусто, то
      #    загружается последняя версия, а в противном случае — с указанной
      #    версией.
      #
      # Возвращает, успешно ли прошёл процесс загрузки и распаковки.
      # @return [Boolean]
      #   успешно ли прошёл процесс загрузки и распаковки
      def fetch
        name.empty? ? fetch_all : fetch_gem
      end

      private

      # Название библиотеки
      # @return [#to_s]
      #   название библиотеки
      attr_reader :name

      # Загружает с сервера библиотек и распаковывает недостающие библиотеки с
      # бизнес-логикой, после чего возвращает, успешно ли прошёл процесс.
      # Пропускает библиотеки, названия которых не заканчивается на строку
      # {SUFFIX}.
      # @return [Boolean]
      #   успешно ли прошёл процесс загрузки и распаковки
      def fetch_all
        obsolete_gems.inject(true) do |memo, (name, version)|
          Fetcher.fetch(name, version) & memo
        end
      end

      # Регулярное выражение, позволяющее извлечь название и версию библиотеки
      # из названия директории с библиотекой
      # @example
      #   test_case-0.0.1 ~> test_case, 0.0.1
      NAME_REGEXP = /\A([a-z][a-z0-9_]*)-([0-9.]*)\z/

      # Возвращает ассоциативный массив, в котором названиям уже загруженных
      # библиотек соответствуют их последние версии
      # @return [Hash{String => String}]
      #   результирующий ассоциативный массив
      def current_gems
        @current_gems ||=
          Dir["#{gems_dir}/*"].each_with_object({}) do |path, memo|
            _, name, version = NAME_REGEXP.match(File.basename(path))&.to_a
            next if name.nil?
            memo[name] = version if memo[name].nil? || memo[name] < version
          end
      end

      # Суффикс названий библиотек с бизнес-логикой
      SUFFIX = '_case'

      # Возвращает ассоциативный массив, в котором названиям устаревших
      # библиотек соответствуют их последние версии на сервере библиотек.
      # Пропускает названия библиотек, названия которых не заканчиваются на
      # строку {SUFFIX}.
      # @return [Hash]
      #   результирующий ассоциативный массив
      def obsolete_gems
        latest_versions = Requests::LatestVersions.latest_versions
        latest_versions.each_with_object({}) do |(name, version), memo|
          next unless name.end_with?(SUFFIX)
          current = current_gems[name]
          memo[name] = version if current.nil? || current < version
        end
      end

      # Загружает и распаковывает библиотеку с названием {name} версии
      # {version}, после чего возвращает, успешно ли прошёл процесс загрузки и
      # распаковки
      # @return [Boolean]
      #   успешно ли прошёл процесс загрузки и распаковки
      def fetch_gem
        log_fetch_start(name, @version, binding)
        extract_entries
        log_fetch_finish(name, version, binding)
        true
      rescue StandardError => e
        log_fetch_error(e, binding)
        false
      end

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
        return extract_file(entry)      if entry.file?
        return extract_directory(entry) if entry.directory?
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
