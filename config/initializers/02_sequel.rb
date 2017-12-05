# encoding: utf-8

# @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
#
# Файл настройки Sequel
#

require 'sequel'
require 'erb'
require 'yaml'

# Подключение расширений Sequel
#
# Подключение поддержки миграций
Sequel.extension :migration
# Подключаем расширения базовых классов
Sequel.extension :core_extensions
# Подключаем расширения для работы с массивами Postgres
Sequel.extension :pg_array_ops

# Инициализация подключения к базе данных
#
# Загрузка настройки базы данных
intermediate = ERB.new(IO.read("#{$root}/config/database.yml")).result
database_options = YAML.safe_load(intermediate, [], [], true)
# Осуществление подключения
db = Sequel.connect(database_options[$environment])
# Добавление журнала событий
db.loggers << $logger unless $environment == 'production'
# Установка того, на каком уровне журнала событий происходит отображение
# SQL-запросов
db.sql_log_level = :debug
# Подключение поддержки списков Postgres
db.extension :pg_array
# Подключение поддержки типов Postgres JSON и JSONB
db.extension :pg_json
# Подключение поддержки перечислимых типов Postgres. Важно, что подключение
# расширения pg_enum идёт после подключения расширения Sequel migration.
db.extension :pg_enum
# Подключение поддержки `nil` в списках значений при фильтрации по атрибуту
db.extension :split_array_nil

# Настройка моделей
#
# Установка базу данных для моделей. Через свойство Sequel::Model.db в
# дальнейшем можно обращаться к базе данных.
Sequel::Model.db = db
# Подключение поддержки генерации исключений
Sequel::Model.raise_on_save_failure = true
Sequel::Model.raise_on_typecast_failure = true
# Подключение общих плагинов
Sequel::Model.plugin :string_stripper

# Загрузка моделей
Dir["#{$lib}/models/**/*.rb"].each do |filename|
  begin
    require filename
  rescue
    nil
  end
end
