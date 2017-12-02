# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл настройки STOMP-контроллера
#

# Загрузка STOMP-контроллера
require "#{$lib}/api/stomp/controller.rb"

connection_info =
  YAML.load(ERB.new(IO.read("#{$root}/config/stomp.yml")).result)

# Установка конфигурации STOMP-контроллера
CaseCore::API::STOMP::Controller.configure do |settings|
  settings.set :connection_info, connection_info
end
