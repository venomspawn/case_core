# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл инициализации сервиса
#

require 'logger'
require 'dotenv'

# Корневая директория
$root = File.absolute_path("#{__dir__}/..")

# Окружение
$environment = ENV['RACK_ENV'] || 'development'

# Загружаем переменные окружения из .env файла
Dotenv.load(File.absolute_path("#{$root}/.env.#{$environment}"))

$logger = Logger.new(STDOUT)
$logger.level = ENV['CC_LOG_LEVEL'] || Logger::DEBUG
$logger.progname = $PROGRAM_NAME
$logger.formatter = proc do |severity, time, progname, message|
  "[#{progname}] [#{time.strftime('%F %T')}] #{severity.upcase}: #{message}\n"
end

$app_name = 'case_core'
$lib = "#{$root}/lib/#{$app_name}"

# Загружаем инициализацию составных частей приложения
Dir["#{__dir__}/initializers/*.rb"].sort.each(&method(:require))

# Загружаем инициализацию, связанную с окружением
Dir["#{__dir__}/environments/*.rb"].sort.each(&method(:require))
