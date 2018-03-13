# frozen_string_literal: true

# Файл настройки STOMP-контроллера

# Загрузка STOMP-контроллера
require "#{$lib}/api/stomp/controller.rb"

# Настройка соединения с брокером сообщений
intermediate = ERB.new(IO.read("#{$root}/config/stomp.yml")).result
connection_info = YAML.safe_load(intermediate, [Symbol], [], true)

# Значение переменных окружения, означающее, что необходимо передать строки,
# созданные с помощью случайных значений
random_queue = '<random>'

# Настройка очереди управляющих сообщений
incoming_queue = ENV['CC_STOMP_INCOMING_QUEUE'] || random_queue
if incoming_queue == random_queue
  incoming_queue = format('case_core.incoming-%03d.queue', rand(1..999))
end

# Настройка очередей ответных сообщений СМЭВ. Названия очередей могут быть
# перечислены через запятую в соответствующей переменной окружения.
response_queues = ENV['CC_STOMP_RESPONSE_QUEUE'] || '<random>'
response_queues = response_queues.split(',').map do |queue|
  next queue unless queue == random_queue
  format('case_core.response-%03d.queue', rand(1..999))
end

# Установка конфигурации STOMP-контроллера
CaseCore::API::STOMP::Controller.configure do |settings|
  settings.set :connection_info, connection_info
  settings.set :incoming_queue,  incoming_queue
  settings.set :response_queues, response_queues
end
