# frozen_string_literal: true

require 'rest-client'

module CaseCore
  module Tasks
    class Transfer
      # Подключаемый модуль, предоставляющий доступ к файловому хранилищу
      module DocumentFiles
        # Адрес сервера файлового хранилища
        HOST = ENV['CC_FS_HOST']

        # Порт сервера файлового хранилища
        PORT = ENV['CC_FS_PORT']

        # URL метода извлечения тела файла
        URL = "http://#{HOST}:#{PORT}/file-storage/api/files"

        # Параметры метода извлечения тела файла
        PARAMS = { params: { directory: 'mfc' } }.freeze

        # Загружает тело файла с предоставленным идентификатором и возвращает
        # его или `nil`, если тело файла пусто или во время загрузки файла
        # произошла ошибка
        # @param [String] id
        #   идентификатор файла
        # @return [String]
        #   загруженное тело файла
        # @return [NilClass]
        #   если тело файла пусто или во время загрузки произошла ошибка
        def file(id)
          body = RestClient.get("#{URL}/#{id}", PARAMS).body
          body unless body.empty?
        rescue StandardError
          nil
        end
      end
    end
  end
end
