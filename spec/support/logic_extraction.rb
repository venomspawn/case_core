# frozen_string_literal: true

# Добавление проверки на то, распаковалась ли загруженная библиотека с
# бизнес-логикой или нет

RSpec::Matchers.define :extract_logic_file do |filepath|
  match do |object|
    object.call
    File.exist?(filepath)
  end

  supports_block_expectations
end
