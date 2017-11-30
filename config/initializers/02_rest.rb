# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл настройки REST-контроллера
#

# Загружаем REST-контроллер
require "#{$lib}/api/rest.rb"
Dir["#{$lib}/api/rest/**/*.rb"].each(&method(:require))

$app = CaseCore::API::REST::Application

# Устанавливаем конфигурацию REST-контроллера
$app.configure do |settings|
  settings.set    :bind, ENV['CC_BIND']
  settings.set    :port, ENV['CC_PORT']

  settings.disable :show_exceptions
  settings.enable  :dump_errors
  settings.enable  :raise_errors

  settings.use    Rack::CommonLogger, $logger

  settings.enable :static
  settings.set    :root, $root
end
