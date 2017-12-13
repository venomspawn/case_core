# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл настройки сканирования директории с распакованными библиотеками
# бизнес-логики
#

# Загрузка сканера директории с распакованными библиотеки бизнес-логики
require "#{$lib}/logic/scanner"

# Установка конфигурации сканера
CaseCore::Logic::Scanner.configure do |settings|
  settings.set :dir_check_period, 10
end
