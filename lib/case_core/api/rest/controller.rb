# frozen_string_literal: true

require 'json'
require 'oj'
require 'sinatra/base'

require_relative 'helpers'

module CaseCore
  # Пространство имён для API
  module API
    # Пространство имён для REST API
    module REST
      # Класс контроллера REST API, основанный на Sinatra
      class Controller < Sinatra::Base
        helpers Helpers

        before do
          content_type 'application/json; charset=utf-8'
        end
      end
    end
  end
end
