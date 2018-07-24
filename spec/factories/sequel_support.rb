# frozen_string_literal: true

# Поддержка Sequel в FactoryBot

FactoryBot.define do
  to_create do |record|
    next record.save unless record.class.restrict_primary_key?
    record.class.unrestrict_primary_key
    record.save
    record.class.restrict_primary_key
  end
end
