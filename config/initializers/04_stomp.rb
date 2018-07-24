# frozen_string_literal: true

# Настройки STOMP-контроллера

# Загрузка STOMP-контроллера
CaseCore.need 'api/stomp/controller'

# Настройка соединения с брокером сообщений
erb = IO.read("#{CaseCore.root}/config/stomp.yml")
yaml = ERB.new(erb).result
connection_info = YAML.safe_load(yaml, [Symbol], [], true)

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

# Функция получения правильного значения количества слушателей
natural = proc do |value|
  value &&= Integer(value)
  value ||= 1
  value < 1 ? 1 : value
end

# Настройка количества слушателей очереди управляющих сообщений
incoming_listeners = natural[ENV['CC_STOMP_INCOMING_LISTENERS']]

# Настройка количества слушателей каждой очереди ответных сообщений СМЭВ
response_listeners = natural[ENV['CC_STOMP_RESPONSE_LISTENERS']]

# Установка конфигурации STOMP-контроллера
CaseCore::API::STOMP::Controller.configure do |settings|
  settings.set :connection_info,    connection_info
  settings.set :incoming_queue,     incoming_queue
  settings.set :incoming_listeners, incoming_listeners
  settings.set :response_queues,    response_queues
  settings.set :response_listeners, response_listeners
end
