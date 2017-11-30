# encoding: utf-8

require "#{$lib}/actions/cases"
require "#{$lib}/actions/documents"
require "#{$lib}/actions/registers"
require "#{$lib}/actions/requests"
require "#{$lib}/helpers/log"

module CaseCore
  module API
    module REST
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Модуль вспомогательных функций для REST-контроллера
      #
      module Helpers
        include CaseCore::Helpers::Log

        # Возвращает название сервиса в верхнем регистре без знаков
        # подчёркивания и дефисов. Необходимо для журнала событий.
        #
        # @return [String]
        #   преобразованное название сервиса
        #
        def app_name_upcase
          $app_name.upcase.tr('-', '_')
        end

        # Добавляет в журнал событий запись о запросе
        #
        def log_request
          log_debug(binding) { <<-LOG }
            #{app_name_upcase} #{request.request_method} REQUEST WITH URL
            #{request.url} AND PARAMS #{params}"
          LOG
        end

        # Добавляет в журнал событий запись о возвращаемом ответе
        #
        def log_response
          log_debug(binding) do
            parts = [app_name_upcase, 'RESPONSE WITH STATUS', response.status]
            parts.push('AND BODY', body) if body.present?
            parts.join(' ')
          end
        end

        # Возвращает объект, предоставляющий действия над записями заявок
        #
        # @return [#index, #show]
        #   объект, предоставляющий действия над записями заявок
        #
        def cases
          Actions::Cases
        end

        # Возвращает объект, предоставляющий действия над записями документов,
        # прикреплённых к заявкам
        #
        # @return [#index]
        #   объект, предоставляющий действия над записями документов,
        #   прикреплённых к заявкам
        #
        def documents
          Actions::Documents
        end

        # Возвращает объект, предоставляющий действия над записями
        # межведомственных запросов, созданными в рамках заявок
        #
        # @return [#index]
        #   объект, предоставляющий действия над записями межведомственных
        #   запросов, созданными в рамках заявок
        #
        def requests
          Actions::Requests
        end

        # Возвращает объект, предоставляющий действия над записями реестров
        # передаваемой корреспонденции
        #
        # @return [#index, #show]
        #   объект, предоставляющий действия над записями реестров передаваемой
        #   корреспонденции
        #
        def registers
          Actions::Registers
        end
      end
    end
  end
end
