# frozen_string_literal: true

# Файл настройки REST-контроллера

# Загрузка REST-контроллера
require "#{$lib}/api/rest/controller.rb"
Dir["#{$lib}/api/rest/**/*.rb"].each(&method(:require))

# Установка конфигурации REST-контроллера
CaseCore::API::REST::Controller.configure do |settings|
  settings.set    :bind, ENV['CC_BIND']
  settings.set    :port, ENV['CC_PORT']

  settings.disable :show_exceptions
  settings.disable :dump_errors
  settings.enable  :raise_errors

  settings.use    Rack::CommonLogger, $logger

  settings.enable :static
  settings.set    :root, $root
end

# Установка сервера Puma в продуктивном режиме
CaseCore::API::REST::Controller.configure :production do |settings|
  settings.set :server, :puma
end
