# frozen_string_literal: true

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл настройки загрузки бизнес-логики из внешних библиотек в исполняемый код
#

# Загрузка загрузчика бизнес-логики
require "#{$lib}/logic/loader"

# Установка конфигурации загрузчика бизнес-логики
CaseCore::Logic::Loader.configure do |settings|
  settings.set :dir, "#{$root}/logic"
end
