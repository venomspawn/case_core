# frozen_string_literal: true

module CaseCore
  need 'actions/files'
  need 'helpers/log'

  module Tasks
    class Transfer
      module Importers
        # Класс объектов, импортирующих содержимое файлов
        class File
          include CaseCore::Helpers::Log

          # Импортирует содержимое файла
          # @param [Hash{:fs_id => String, :created_at => Time}] doc
          #   ассоциативный массив с информацией о документе
          def self.import(doc)
            new(doc).import
          end

          # Инициализирует объект класса
          # @param [Hash{:fs_id => String, :created_at => Time}] doc
          #   ассоциативный массив с информацией о документе
          def initialize(doc)
            @doc = doc
          end

          # Импортирует содержимое файла
          def import
            return if fs_id.nil?
            log_file_content(fs_id, content)
            return if content.nil?

          end

          private

          # Объект, предоставляющий доступ к данным
          # @return [Hash{:fs_id => String, :created_at => Time}]
          #   ассоциативный массив с информацией о документе
          attr_reader :doc

          # Возвращает идентификатор файла в файловом хранилище
          # @return [String]
          #   идентификатор файла в файловом хранилище
          def fs_id
            @fs_id ||= doc[:fs_id]
          end

          # Регулярное выражение для отбрасывания символов, не являющихся
          # шестнадцатеричными символами
          NOT_HEX = /[^a-fA-F0-9]/

          # Длина строки с шестнадцатеричным представлением UUID
          UUID_SIZE = 32

          # Диапазон для отсекания лишних символов
          TAIL = (UUID_SIZE..-1).freeze

          # Диапазоны для выделения частей текстового представления UUID
          RANGES = [0..7, 8..11, 12..15, 16..19, 20..31].freeze

          # Разделителей частей в текстовом представлении UUID
          DELIMITER = '-'

          # Возвращает текстовое представление UUID, созданное на основе
          # предоставленной строки
          # @return [String]
          #   результирующее текстовое представление UUID
          def id
            return @id unless @id.nil?
            @id = fs_id.dup
            @id.gsub!(NOT_HEX, '')
            @id << SecureRandom.hex(UUID_SIZE)
            @id.slice!(TAIL)
            @id = RANGES.map(@id.method(:[])).join(DELIMITER)
          end

          # Адрес сервера файлового хранилища
          HOST = ENV['CC_FS_HOST']

          # Порт сервера файлового хранилища
          PORT = ENV['CC_FS_PORT']

          # URL метода извлечения тела файла
          URL = "http://#{HOST}:#{PORT}/file-storage/api/files"

          # Параметры метода извлечения тела файла
          PARAMS = {
            method:  :get,
            headers: { params: { directory: 'mfc' } }
          }.freeze

          # Загружает тело файла с предоставленным идентификатором и возвращает
          # объект с информацией о нём или `nil`, если тело файла пусто или во
          # время загрузки файла произошла ошибка
          # @return [Tempfile]
          #   объект с информацией о файле
          # @return [NilClass]
          #   если тело файла пусто или во время загрузки произошла ошибка
          def content
            response =
              RestClient::Request.execute(url: "#{URL}/#{id}", **PARAMS)
            response.file.open
            response.file unless response.file.size.zero?
          rescue StandardError
            nil
          end

          # Создаёт запись в журнале событий о результате извлечения тела файла
          # из файлового хранилища
          # @param [String] fs_id
          #   идентификатор файла
          # @param [#size] content
          #   объект с информацией о содержимом файла
          def log_file_content(fs_id, content)
            content.nil? ? log_warn { <<-ERROR } : log_info { <<-SUCCESS }
              Не удалось скачать файл с идентификатором #{fs_id}
            ERROR
              Файл с идентификатором #{fs_id} успешно скачан, количество байт —
              #{content.size}
            SUCCESS
          end
        end
      end
    end
  end
end
