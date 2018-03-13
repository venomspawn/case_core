# frozen_string_literal: true

namespace :case_core do
  desc 'Осуществляет миграцию базы данных сервиса'
  task :migrate, [:to, :from] do |_task, args|
    require_relative 'config/app_init'

    require "#{$lib}/tasks/migration"

    to = args[:to]
    from = args[:from]
    dir = "#{$root}/db/migrations"
    db = Sequel::Model.db
    CaseCore::Tasks::Migration.launch!(db, to, from, dir)
  end

  desc 'Загружает и распаковывает библиотеку с бизнес-логикой'
  task :fetch_logic, [:name, :version] do |_task, args|
    require_relative 'config/app_init'

    name = args[:name]
    version = args[:version]
    CaseCore::Logic::Fetcher.fetch(name, version)
  end

  desc 'Запускает контроллер REST API'
  task :run_rest_controller do
    require_relative 'config/app_init'

    CaseCore::API::REST::Controller.run!
  end

  desc 'Запускает контроллер REST API'
  task :run_stomp_controller do
    require_relative 'config/app_init'

    CaseCore::API::STOMP::Controller.run!
  end
end
