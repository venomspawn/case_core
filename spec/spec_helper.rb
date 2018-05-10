# frozen_string_literal: true

# Файл поддержки тестирования

$VERBOSE = nil

require 'rspec'

show_delay_info = -> { $logger.unknown { <<-MESSAGE.squish } }
  Выставлена задержка #{RSpec.configuration.delay} при тестировании
  многопоточных конструкций
MESSAGE

RSpec.configure do |config|
  # Исключение поддержки конструкций describe без префикса RSpec.
  config.expose_dsl_globally = false
  # Настройка задержек при тестировании многопоточных конструкций
  config.add_setting :delay, default: 0.1

  config.before(:suite) { show_delay_info.call }
  config.after(:suite) { show_delay_info.call }
end

RSpec::Matchers.define_negated_matcher :not_change, :change

require_relative '../config/app_init'
CaseCore::Init.run!

spec = File.absolute_path(__dir__)
Dir["#{spec}/helpers/**/*.rb"].each(&method(:require))
Dir["#{spec}/shared/**/*.rb"].each(&method(:require))
Dir["#{spec}/support/**/*.rb"].each(&method(:require))
