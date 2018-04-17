# frozen_string_literal: true

require "#{$lib}/actions/cases"
require "#{$lib}/actions/documents"
require "#{$lib}/actions/processing_statuses"
require "#{$lib}/actions/requests"
require "#{$lib}/actions/version"

module CaseCore
  module API
    module REST
      # Модуль вспомогательных функций для REST-контроллера
      module Helpers
        # Приводит значения ассоциативного массива у указанных ключей к типу
        # целых чисел, если эти ключи присутствуют в ассоциативном массиве
        # @param [Hash] hash
        #   ассоциативный массив
        # @param [Array] keys
        #   список ключей
        # @raise [ArgumentError]
        #   если какое-то из значений невозможно привести к типу целых чисел
        def make_integer(hash, *keys)
          keys.each { |key| hash[key] &&= Integer(hash[key]) }
        end

        # Возвращает объект, предоставляющий действия над записями заявок
        # @return [#index, #show]
        #   объект, предоставляющий действия над записями заявок
        def cases
          Actions::Cases
        end

        # Возвращает объект, предоставляющий действия над записями документов,
        # прикреплённых к заявкам
        # @return [#index]
        #   объект, предоставляющий действия над записями документов,
        #   прикреплённых к заявкам
        def documents
          Actions::Documents
        end

        # Возвращает объект, предоставляющий действия над записями
        # межведомственных запросов, созданными в рамках заявок
        # @return [#index]
        #   объект, предоставляющий действия над записями межведомственных
        #   запросов, созданными в рамках заявок
        def requests
          Actions::Requests
        end

        # Возвращает объект, предоставляющий действия над записями статусов
        # обработки сообщений STOMP
        # @return [#show]
        #   объект, предоставляющий действия над записями статусов обработки
        #   сообщений STOMP
        def processing_statuses
          Actions::ProcessingStatuses
        end

        # Возвращает объект, предоставляющий действия, которые возвращают
        # информацию о версии сервиса и модулей бизнес-логики
        # @return [#show]
        #   объект, предоставляющий действия, которые возвращают информацию о
        #   версии сервиса и модулей бизнес-логики
        def version
          Actions::Version
        end
      end
    end
  end
end
