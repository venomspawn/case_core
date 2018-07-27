# frozen_string_literal: true

require_relative 'base/specs'

module CaseCore
  need 'helpers/log'

  module Logic
    class Fetcher
      module Requests
        # Класс запросов к серверу библиотек, который предоставляет функцию
        # `latest_versions`, возвращающую информацию о последних версиях
        # всех библиотек на сервере библиотек
        class LatestVersions < Base::Specs
          include CaseCore::Helpers::Log

          # Возвращает ассоциативный массив с информацией о последних версиях
          # всех библиотек на сервере библиотек. Возвращает пустой
          # ассоциативный массив в случае, если во время загрузки или
          # извлечения этой информации произошла ошибка.
          # @return [Hash{String => String}]
          #   ассоциативный массив, в котором ключами являются названия
          #   библиотек, а значениями — их последние версии
          def self.latest_versions
            new.latest_versions
          end

          # Возвращает ассоциативный массив с информацией о последних версиях
          # всех библиотек на сервере библиотек. Возвращает пустой
          # ассоциативный массив в случае, если во время загрузки или
          # извлечения этой информации произошла ошибка.
          # @return [Hash{String => String}]
          #   ассоциативный массив, в котором ключами являются названия
          #   библиотек, а значениями — их последние версии
          def latest_versions
            specs.each_with_object({}) do |(name, version), memo|
              version = version.to_s
              memo[name] = version unless memo[name]&.>=(version)
            end
          rescue StandardError => err
            log_latest_versions_error(err, binding)
            {}
          end

          private

          # Создаёт запись в журнале событий о том, что во время загрузки или
          # извлечения информации о последних версиях библиотек произошла
          # ошибка
          # @param [Exception] err
          #   объект с информацией об ошибке
          # @param [Binding] context
          #   контекст
          def log_latest_versions_error(err, context)
            log_error(context) { <<-LOG }
              Во время загрузки или извлечения информации о последних версиях
              библиотек произошла ошибка `#{err.class}`: `#{err.message}`
            LOG
          end
        end
      end
    end
  end
end
