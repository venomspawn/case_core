# frozen_string_literal: true

module CaseCore
  need 'requests/get'
  need 'requests/mixins/url'

  module Logic
    class Fetcher
      # Пространство имён классов запросов к серверу библиотек
      module Requests
        # Пространство имён базовых классов запросов к серверу библиотек
        module Base
          # Базовый класс запросов к серверу библиотек
          class Request
            include CaseCore::Requests::Get
            include CaseCore::Requests::Mixins::URL

            private

            # Возвращает адрес сервера библиотек
            # @return [#to_s]
            #   адрес сервера библиотек
            def host
              Fetcher.settings.gem_server_host
            end

            # Возвращает порт сервера библиотек
            # @return [#to_s]
            #   порт сервера библиотек
            def port
              Fetcher.settings.gem_server_port
            end

            # Возвращает базовый путь к библиотекам
            # @return [String]
            #   базовый путь к библиотекам
            def path
              Fetcher.settings.gem_server_path
            end
          end
        end
      end
    end
  end
end
