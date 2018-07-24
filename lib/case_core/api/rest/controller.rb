# frozen_string_literal: true

require 'sinatra/base'

module CaseCore
  # Пространство имён для API
  module API
    # Пространство имён для REST API
    module REST
      # Класс контроллера REST API, основанный на Sinatra
      class Controller < Sinatra::Base
        # Тип содержимого, возвращаемого REST API методами
        CONTENT_TYPE = 'application/json; charset=utf-8'

        before { content_type CONTENT_TYPE }
      end
    end
  end
end
