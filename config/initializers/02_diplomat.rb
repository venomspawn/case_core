# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл настройки библиотеки `diplomat`
#

require 'diplomat'

consul_schema = ENV['CC_CONSUL_SCHEMA'] || 'http'
consul_host   = ENV['CC_CONSUL_HOST']   || '169.254.1.1'
consul_port   = ENV['CC_CONSUL_PORT']   || 8500

# Настройка библиотеки `diplomat`
Diplomat.configure do |settings|
  settings.url = "#{consul_schema}://#{consul_host}:#{consul_port}"
  settings.options = { request: { timeout: 0.5 } }
end
