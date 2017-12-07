# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл настройки загрузки бизнес-логики
#

# Загрузка загрузчика бизнес-логики
require "#{$lib}/logic/loader"

# Установка конфигурации загрузчика бизнес-логики
CaseCore::Logic::Loader.configure do |settings|
  settings.set :dir,              "#{$root}/logic"
  settings.set :dir_check_period, 1
end
