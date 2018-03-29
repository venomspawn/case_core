# frozen_string_literal: true

# Файл настройки загрузки бизнес-логики из внешних библиотек в исполняемый код

# Загрузка загрузчика бизнес-логики
require "#{$lib}/logic/loader"

# Установка конфигурации загрузчика бизнес-логики
CaseCore::Logic::Loader.configure do |settings|
  settings.set :dir, "#{$root}/#{ENV['CC_LOGIC_DIR']}"
end
