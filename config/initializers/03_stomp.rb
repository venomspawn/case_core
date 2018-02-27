# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл настройки STOMP-контроллера
#

# Загрузка STOMP-контроллера
require "#{$lib}/api/stomp/controller.rb"

# Настройка соединения с брокером сообщений
connection_info =
  YAML.load(ERB.new(IO.read("#{$root}/config/stomp.yml")).result)

# Настройка очереди управляющих сообщений
incoming_queue = ENV['CC_STOMP_INCOMING_QUEUE'] || 'case_core.incoming.queue'

# Настройка очередей ответных сообщений СМЭВ. Названия очередей могут быть
# перечислены через запятую в соответствующей переменной окружения.
response_queues = ENV['CC_STOMP_RESPONSE_QUEUE'] || 'case_core.response.queue'
response_queues = response_queues.split(',')

# Установка конфигурации STOMP-контроллера
CaseCore::API::STOMP::Controller.configure do |settings|
  settings.set :connection_info, connection_info
  settings.set :incoming_queue,  incoming_queue
  settings.set :response_queues, response_queues
end
