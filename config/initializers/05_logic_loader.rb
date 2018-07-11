# frozen_string_literal: true

# Настройки загрузки бизнес-логики из внешних библиотек в исполняемый код

CaseCore.need 'logic/loader'

# Установка конфигурации загрузчика бизнес-логики
CaseCore::Logic::Loader.configure do |settings|
  settings.set :dir, "#{CaseCore.root}/#{ENV['CC_LOGIC_DIR']}"
end
