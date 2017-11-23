# encoding: utf-8

namespace :case_core do
  # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
  #
  desc 'Осуществляет миграцию базы данных сервиса'
  task :migrate, [:to, :from] do |_task, args|
    # Загружаем начальную конфигурацию, в которой находится настройка
    # соединения с базой
    require_relative 'config/app_init'

    # Загружаем класс объектов, осуществляющих миграцию
    require "#{$lib}/tasks/migration"

    # Создаём соответствующий объект и запускаем миграцию
    to = args[:to]
    from = args[:from]
    dir = "#{$root}/db/migrations"
    db = Sequel::Model.db
    CaseCore::Tasks::Migration.launch!(db, to, from, dir)
  end
end
