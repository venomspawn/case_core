# frozen_string_literal: true

require_relative 'base/specs'

module CaseCore
  need 'helpers/log'

  module Logic
    class Fetcher
      module Requests
        # Класс запросов к серверу библиотек, который предоставляет функцию
        # `latest_version`, возвращающую информацию о новейшей версии
        # библиотеки с заданным названием на сервере библиотек
        class LatestVersion < Base::Specs
          include CaseCore::Helpers::Log

          # Возвращает строку с информацией о новейшей версии библиотеки с
          # заданным названием, извлечённой из сервера библиотек, или `nil` в
          # случае, если библиотека отсутствует на сервере библиотек или во
          # время загрузки информации произошла ошибка
          # @param [#to_s] name
          #   название библиотеки
          # @return [String]
          #   строка с новейшей версией библиотеки на сервере библиотек
          # @return [NilClass]
          #   если библиотека отсутствует на сервере библиотек или во время
          #   загрузки информации произошла ошибка
          def self.latest_version(name)
            new(name).latest_version
          end

          # Инициализирует объект класса
          # @param [#to_s] name
          #   название библиотеки
          def initialize(name)
            @name = name.to_s
          end

          # Возвращает строку с информацией о новейшей версии библиотеки с
          # заданным названием, извлечённой из сервера библиотек, или `nil` в
          # случае, если библиотека отсутствует на сервере библиотек или во
          # время загрузки информации произошла ошибка
          # @return [String]
          #   строка с новейшей версией библиотеки на сервере библиотек
          # @return [NilClass]
          #   если библиотека отсутствует на сервере библиотек или во время
          #   загрузки информации произошла ошибка
          def latest_version
            result = specs.reduce(nil) do |memo, (spec_name, version)|
              next memo unless spec_name == name
              memo.nil? || memo < version ? version : memo
            end
            result&.to_s
          rescue StandardError => err
            log_latest_version_error(err, binding)
          end

          private

          # Строка с названием библиотеки
          # @return [String]
          #   строка с названием библиотеки
          attr_reader :name

          # Создаёт запись в журнале событий о том, что во время загрузки или
          # извлечения информации о последней версии библиотеки произошла
          # ошибка
          # @param [Exception] err
          #   объект с информацией об ошибке
          # @param [Binding] context
          #   контекст
          def log_latest_version_error(err, context)
            log_error(context) { <<-LOG }
              Во время загрузки или извлечения информации о последней версии
              библиотеки `#{name}` произошла ошибка `#{err.class}`:
              `#{err.message}`
            LOG
          end
        end
      end
    end
  end
end
