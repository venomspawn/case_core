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

  desc 'Запускает автоматическое обновление библиотек'
  task :run_fetcher do
    require_relative 'config/app_init'

    CaseCore::Init.run!(only: %w[oj censorship class_ext logger logic_fetcher])

    require 'rufus-scheduler'

    cron_line = ENV['CC_FETCHER_CRON']
    cron = Fugit::Cron.parse(cron_line) unless cron_line.to_s.empty?

    %w[INT TERM].each do |signal|
      previous_handler = trap(signal) do
        Thread.exit
        previous_handler.call
      end
    end

    # Загрузка всех обновлений
    CaseCore::Logic::Fetcher.fetch

    # Усыпление процесса в случае, если значение переменной окружения не
    # является корректной cron-строкой
    sleep if cron.nil?

    scheduler = Rufus::Scheduler.new
    scheduler.cron(cron, &CaseCore::Logic::Fetcher.method(:fetch))
    scheduler.join
  end

  desc 'Запускает автоматическое удаление неприкреплённых записей файлов'
  task :run_dfc do
    require_relative 'config/app_init'

    CaseCore::Init.run!(only: %w[class_ext logger sequel])

    require 'rufus-scheduler'

    cron_line = ENV['CC_DFC_CRON']
    cron = Fugit::Cron.parse(cron_line) unless cron_line.to_s.empty?

    death_age = ENV['CC_DFC_AGE'].to_i

    %w[INT TERM].each do |signal|
      previous_handler = trap(signal) do
        Thread.exit
        previous_handler.call
      end
    end

    # Усыпление процесса в случае, если значения требуемых переменных окружения
    # не являются корректными
    sleep if cron.nil? || death_age.zero? || death_age.negative?

    CaseCore.need 'collectors/files/sweep'

    scheduler = Rufus::Scheduler.new
    scheduler.cron(cron) do
      CaseCore::Collectors::Files::Sweep.invoke(death_age)
    end
    scheduler.join
  end

  desc 'Запускает автоматическое удаление записей атрибутов со значением `nil`'
  task :run_eac do
    require_relative 'config/app_init'

    CaseCore::Init.run!(only: %w[class_ext logger sequel])

    require 'rufus-scheduler'

    cron_line = ENV['CC_EAC_CRON']
    cron = Fugit::Cron.parse(cron_line) unless cron_line.to_s.empty?

    %w[INT TERM].each do |signal|
      previous_handler = trap(signal) do
        Thread.exit
        previous_handler.call
      end
    end

    # Усыпление процесса в случае, если значения требуемых переменных окружения
    # не являются корректными
    sleep if cron.nil?

    CaseCore.need 'collectors/case_attributes/sweep'
    CaseCore.need 'collectors/request_attributes/sweep'

    scheduler = Rufus::Scheduler.new
    scheduler.cron(cron) do
      CaseCore::Collectors::CaseAttributes::Sweep.invoke
      CaseCore::Collectors::RequestAttributes::Sweep.invoke
    end
    scheduler.join
  end

  desc 'Запускает миграцию данных из `case_manager`'
  task :transfer do
    require_relative 'config/app_init'

    CaseCore::Init.run!(only: %w[class_ext oj logger sequel models transfer])

    CaseCore::Tasks::Transfer.launch!
  end
end
