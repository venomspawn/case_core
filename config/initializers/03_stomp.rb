# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл настройки STOMP-контроллера
#

# Загрузка STOMP-контроллера
require "#{$lib}/api/stomp/controller.rb"

connection_info =
  YAML.load(ERB.new(IO.read("#{$root}/config/stomp.yml")).result)
incoming_queue = ENV['CC_STOMP_INCOMING_QUEUE'] || 'case_core.incoming.queue'
response_queue = ENV['CC_STOMP_RESPONSE_QUEUE'] || 'case_core.response.queue'

# Установка конфигурации STOMP-контроллера
CaseCore::API::STOMP::Controller.configure do |settings|
  settings.set :connection_info, connection_info
  settings.set :incoming_queue,  incoming_queue
  settings.set :response_queue,  response_queue
end
