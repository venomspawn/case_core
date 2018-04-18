# frozen_string_literal: true

# Файл загрузки классов действий

Dir["#{$lib}/actions/*.rb"].each(&method(:require))
