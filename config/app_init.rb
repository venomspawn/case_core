# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл инициализации сервиса
#

require 'dotenv'

# Корневая директория
$root = File.absolute_path("#{__dir__}/..")

# Окружение
$environment = ENV['RACK_ENV'] || 'development'

# Загрузка переменных окружения из .env файла
Dotenv.load(File.absolute_path("#{$root}/.env.#{$environment}"))

$app_name = 'case_core'
$lib = "#{$root}/lib/#{$app_name}"

# Загрузка инициализации составных частей приложения
Dir["#{__dir__}/initializers/*.rb"].sort.each(&method(:require))

# Загрузка инициализации, связанной с окружением
Dir["#{__dir__}/environments/*.rb"].sort.each(&method(:require))
