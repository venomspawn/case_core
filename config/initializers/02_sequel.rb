# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл настройки Sequel
#

require 'sequel'
require 'erb'
require 'yaml'

# Подключаем расширения Sequel
#
# Подключаем поддержку миграций
Sequel.extension :migration
# Подключаем расширения базовых классов
Sequel.extension :core_extensions
# Подключаем расширения для работы с массивами Postgres
Sequel.extension :pg_array_ops

# Инициализируем подключение к базе данных
#
# Загружаем настройки базы данных
intermediate = ERB.new(IO.read("#{$root}/config/database.yml")).result
database_options = YAML.safe_load(intermediate, [], [], true)
# Осуществляем подключение
db = Sequel.connect(database_options[$environment])
# Добавляем журнал событий
db.loggers << $logger unless $environment == 'production'
# Устанавливаем, на каком уровне журнала событий происходит отображение
# SQL-запросов
db.sql_log_level = :debug
# Подключаем поддержку списков Postgres
db.extension :pg_array
# Подключаем поддержку перечислимых типов Postgres. Важно, что подключение
# расширения pg_enum идёт после подключения расширения Sequel migration.
db.extension :pg_enum

# Настраиваем модели
#
# Устанавливаем базу данных для моделей. Через свойство Sequel::Model.db в
# дальнейшем будем обращаться к базе данных.
Sequel::Model.db = db
# Подключаем поддержку генерации исключений
Sequel::Model.raise_on_save_failure = true
Sequel::Model.raise_on_typecast_failure = true
# Подключаем общие плагины
Sequel::Model.plugin :string_stripper

# Загружаем модели
begin
  Dir["#{$lib}/models/**/*.rb"].each(&method(:require))
rescue
  nil
end
