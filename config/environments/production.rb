# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл инициализации приложения в продуктивном режиме
#

# Установка сервера Puma в продуктивном режиме
CaseCore::API::REST::Controller.configure :production do |settings|
  settings.set :server, :puma
end
