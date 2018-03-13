# frozen_string_literal: true

# Файл настройки фильтрации ключей ассоциативных массивов при выводе их
# значений

require "#{$lib}/censorship/filter"

CaseCore::Censorship::Filter.configure do |settings|
  settings.set :censored_message,    '[CENSORED]'
  settings.set :too_long_message,    '[TOO LONG]'
  settings.set :string_length_limit, 40
end
