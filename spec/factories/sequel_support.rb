# frozen_string_literal: true

# Поддержка Sequel в FactoryGirl

FactoryGirl.define do
  to_create(&:save)
end
