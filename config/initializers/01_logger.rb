# frozen_string_literal: true

# Файл инициализации журнала событий

require 'logger'

# Отключение буферизации стандартного потока вывода
STDOUT.sync = true

$logger = Logger.new(STDOUT)
$logger.level = ENV['CC_LOG_LEVEL'] || Logger::DEBUG
$logger.progname = $app_name
$logger.formatter = proc do |severity, time, progname, message|
  "[#{progname}] [#{time.strftime('%F %T')}] #{severity.upcase}: #{message}\n"
end
