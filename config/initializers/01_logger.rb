# frozen_string_literal: true

# Инициализация журнала событий

require 'logger'

# Отключение буферизации стандартного потока вывода
STDOUT.sync = true

logger = Logger.new(STDOUT)
logger.level = ENV['CC_LOG_LEVEL'] || Logger::DEBUG
logger.progname = $PROGRAM_NAME
logger.formatter = proc do |severity, time, progname, message|
  "[#{progname}] [#{time.strftime('%F %T')}] #{severity.upcase}: #{message}\n"
end

CaseCore::Init.configure do |settings|
  settings.set :logger, logger
end
