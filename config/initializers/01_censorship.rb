# frozen_string_literal: true

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл настройки фильтрации ключей ассоциативных массивов при выводе их
# значений
#

require "#{$lib}/censorship/filter"

CaseCore::Censorship::Filter.configure do |settings|
  settings.set :censored_message,    '[CENSORED]'
  settings.set :too_long_message,    '[TOO LONG]'
  settings.set :string_length_limit, 40
end
