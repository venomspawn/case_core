# frozen_string_literal: true

# Настройки фильтрации ключей ассоциативных массивов при выводе их значений в
# журнале событий

CaseCore.need 'censorship/filter'

CaseCore::Censorship::Filter.configure do |settings|
  settings.set :censored_message,    '[CENSORED]'
  settings.set :too_long_message,    '[TOO LONG]'
  settings.set :string_length_limit, 80
end
