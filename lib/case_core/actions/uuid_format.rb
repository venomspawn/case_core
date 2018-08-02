# frozen_string_literal: true

module CaseCore
  module Actions
    # Выражение для шестнадцатеричной цифры
    HEX = '[a-fA-F0-9]'

    # Регулярное выражение для проверки на формат UUID
    UUID_FORMAT = /\A#{HEX}{8}-#{HEX}{4}-#{HEX}{4}-#{HEX}{4}-#{HEX}{12}\z/
  end
end
