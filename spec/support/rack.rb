# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл поддержки тестирования контроллера Sinatra
#

require 'rack/test'

module Support
  module RackHelper
    include Rack::Test::Methods

    # Тестируемый REST-контроллер
    #
    def app
      CaseCore::API::REST::Controller
    end
  end
end

RSpec.configure do |config|
  config.include Support::RackHelper
end
