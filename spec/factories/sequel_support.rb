# frozen_string_literal: true

# Поддержка Sequel в FactoryBot

FactoryBot.define do
  to_create(&:save)
end
