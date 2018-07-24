# frozen_string_literal: true

namespace :case_core do
  desc 'Осуществляет миграцию базы данных сервиса'
  task :migrate, [:to, :from] do |_task, args|
    require_relative 'config/app_init'

    CaseCore::Init.run!(only: %w[class_ext logger sequel])

    CaseCore.need 'tasks/migration'

    to = args[:to]
    from = args[:from]
    CaseCore::Tasks::Migration.launch!(to, from)
  end

  desc 'Загружает и распаковывает библиотеку с бизнес-логикой'
  task :fetch_logic, [:name, :version] do |_task, args|
    require_relative 'config/app_init'

    CaseCore::Init.run!(only: %w[oj censorship class_ext logger logic_fetcher])

    name = args[:name]
    version = args[:version]
    CaseCore::Logic::Fetcher.fetch(name, version)
  end

  desc 'Запускает контроллер REST API'
  task :run_rest_controller do
    require_relative 'config/app_init'

    CaseCore::Init
      .run!(only: %w[class_ext logger oj sequel models actions rest])

    CaseCore::API::REST::Controller.run!
  end

  desc 'Запускает контроллер STOMP API'
  task :run_stomp_controller do
    require_relative 'config/app_init'

    CaseCore::Init.run!(except: %w[logic_fetcher rest transfer])

    CaseCore::API::STOMP::Controller.run!
  end

  desc 'Запускает миграцию данных из `case_manager`'
  task :transfer do
    require_relative 'config/app_init'

    CaseCore::Init.run!(only: %w[class_ext oj logger sequel models transfer])

    CaseCore::Tasks::Transfer.launch!
  end
end
