# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл поддержки тестирования контроллера Sinatra
#

require 'rack/test'

module Support
  module RackHelper
    include Rack::Test::Methods

    # Тестируемое приложение
    #
    def app
      $app
    end
  end
end

RSpec.configure do |config|
  config.include Support::RackHelper
end
