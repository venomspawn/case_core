# frozen_string_literal: true

# Файл инициализации сервиса

require 'dotenv'

# Корневая директория
$root = File.absolute_path("#{__dir__}/..")

# Окружение
$environment = ENV['RACK_ENV'] || 'development'

# Загрузка переменных окружения из .env файла
Dotenv.load(File.absolute_path("#{$root}/.env.#{$environment}"))

$app_name = 'case_core'
$lib = "#{$root}/lib/#{$app_name}"

# Загрузка системы инициализации
require "#{$lib}/init"

# Настройка системы инициализации
CaseCore::Init.configure do |settings|
  settings.set :initializers, "#{__dir__}/initializers"
end
