# frozen_string_literal: true

# Настройка библиотеки factory_bot

require 'factory_bot'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end

FactoryBot.definition_file_paths = ["#{CaseCore.root}/spec/factories/"]
FactoryBot.find_definitions
