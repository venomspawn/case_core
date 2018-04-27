# frozen_string_literal: true

# Файл настройки загрузки внешних бибилиотек из сервера библиотек в директорию
# с сервисом

# Загрузка загрузчика библиотек
require "#{$lib}/logic/fetcher"

# Установка конфигурации загрузчика библиотек
CaseCore::Logic::Fetcher.configure do |settings|
  settings.set :gem_server_host, ENV['CC_GEM_SERVER_HOST'] || '10.33.68.123'
  settings.set :gem_server_port, ENV['CC_GEM_SERVER_PORT'] || 9292
  settings.set :gem_server_path, ENV['CC_GEM_SERVER_PATH']
  settings.set :logic_dir,       "#{$root}/#{ENV['CC_LOGIC_DIR']}"
end
