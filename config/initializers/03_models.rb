# frozen_string_literal: true

# Загрузка моделей
CaseCore.loglessly { CaseCore.need 'models/*', skip_errors: Sequel::Error }
