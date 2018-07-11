# frozen_string_literal: true

# Инициализация сервиса

require 'dotenv'

# Корневая директория
root = File.absolute_path("#{__dir__}/..")

# Окружение
environment = ENV['RACK_ENV'] || 'development'

# Загрузка переменных окружения из .env файла
Dotenv.load("#{root}/.env.#{environment}")

app_name = 'case_core'
# Загрузка корневого модуля
require "#{root}/lib/#{app_name}"

# Настройка системы инициализации
CaseCore::Init.configure do |settings|
  settings.set :initializers, "#{__dir__}/initializers"
  settings.set :root, root
end
