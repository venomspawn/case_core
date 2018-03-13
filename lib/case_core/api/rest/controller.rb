# frozen_string_literal: true

require 'json'
require 'oj'
require 'sinatra/base'

require_relative 'helpers'

module CaseCore
  # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
  #
  # Пространство имён для API
  #
  module API
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Пространство имён для REST API
    #
    module REST
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Класс контроллера REST API, основанный на Sinatra
      #
      class Controller < Sinatra::Base
        helpers Helpers

        before do
          # Устанавливаем JSON типом содержимого, возвращаемого всеми методами
          content_type 'application/json; charset=utf-8'

          # Создаём в журнале сообщений запись о запросе
          log_request
        end

        after do
          # Создаём в журнале сообщений запись об ответе
          log_response
        end
      end
    end
  end
end
