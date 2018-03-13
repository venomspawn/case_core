# frozen_string_literal: true

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл поддержки тестирования
#

require 'rspec'

RSpec.configure do |config|
  # Убираем поддержку конструкций describe без префикса RSpec.
  config.expose_dsl_globally = false
end

RSpec::Matchers.define_negated_matcher :not_change, :change

require_relative '../config/app_init'

spec = File.absolute_path(__dir__)
Dir["#{spec}/helpers/**/*.rb"].each(&method(:require))
Dir["#{spec}/shared/**/*.rb"].each(&method(:require))
Dir["#{spec}/support/**/*.rb"].each(&method(:require))
