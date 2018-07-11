# frozen_string_literal: true

# Загрузка моделей
CaseCore.need 'models/*', skip_errors: PG::Error
