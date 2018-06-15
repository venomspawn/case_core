# frozen_string_literal: true

# Файл поддержки проверки типов и структур объектов на соответствие JSON-схеме

RSpec::Matchers.define :match_json_schema do |schema|
  match { |object| JSON::Validator.validate(schema, object) }
  description { "match JSON schema #{schema}" }
end

RSpec::Matchers.define :have_proper_body do |schema|
  match { |response| JSON::Validator.validate(schema, response.body) }
  description { "have body that matches JSON schema #{schema}" }
end
