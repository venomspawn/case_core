# frozen_string_literal: true

# Файл поддержки библиотеки factory_girl

require 'factory_girl'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end

FactoryGirl.definition_file_paths = ["#{$root}/spec/factories/"]
FactoryGirl.find_definitions
