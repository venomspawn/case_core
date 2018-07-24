# frozen_string_literal: true

require 'rest-client'

module CaseCore
  need 'actions/files/create'
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
            doc[:fs_id] = Actions::Files::Create.new(content).create[:id]
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
            @fs_id ||= doc.delete(:fs_id)
          end

          # Адрес сервера файлового хранилища
          HOST = ENV['CC_FS_HOST']

          # Порт сервера файлового хранилища
          PORT = ENV['CC_FS_PORT']

          # URL метода извлечения тела файла
          URL_TEMPLATE = "http://#{HOST}:#{PORT}/file-storage/api/files/%s"

          # Возвращает URL содержимого файла
          # @return [String]
          #   URL содержимого файла
          def url
            format(URL_TEMPLATE, fs_id)
          end

          # Параметры метода извлечения тела файла
          PARAMS = {
            method:       :get,
            headers:      { params: { directory: 'mfc' } },
            raw_response: true
          }.freeze

          # Загружает тело файла с предоставленным идентификатором и возвращает
          # объект с информацией о нём или `nil`, если тело файла пусто или во
          # время загрузки файла произошла ошибка
          # @return [Tempfile]
          #   объект с информацией о файле
          # @return [NilClass]
          #   если тело файла пусто или во время загрузки произошла ошибка
          def content
            return @content if defined?(@content)
            response = RestClient::Request.execute(url: url, **PARAMS)
            response.file.open
            @content = response.file.size.zero? ? nil : response.file
          rescue StandardError
            @content = nil
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
