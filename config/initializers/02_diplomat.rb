# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл настройки библиотеки `diplomat`
#

require 'diplomat'

consul_host = ENV['CC_CONSUL_HOST'] || '169.254.1.1'
consul_port = ENV['CC_CONSUL_PORT'] || 8500

# Настройка библиотеки `diplomat`
Diplomat.configure do |settings|
  settings.url = "#{consul_host}:#{consul_port}"
end
