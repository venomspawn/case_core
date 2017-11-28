# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл поддержки библиотеки json-schema-rspec
#

require 'json-schema-rspec'

RSpec.configure do |config|
  config.include JSON::SchemaMatchers

  # Загружаем схемы JSON
  prefix = "#{$root}/spec/fixtures/schemas/"
  suffix = '_schema.json'
  # Регулярное выражение для обрезания префикса и суффикса
  regexp = /#{prefix}(.*)#{suffix}/
  Dir["#{prefix}**/*#{suffix}"].each do |schema_path|
    # Обрезаем префикс и суффикс, заменяем '/' на '_'
    schema = schema_path.gsub(regexp, '\1').tr('/', '_').to_sym
    config.json_schemas[schema] = schema_path
  end
end
