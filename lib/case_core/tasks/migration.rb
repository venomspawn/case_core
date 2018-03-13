# frozen_string_literal: true

require "#{$lib}/helpers/log"

module CaseCore
  # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
  #
  # Пространство имён классов объектов, обслуживающих Rake-задачи
  #
  module Tasks
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Класс объектов, запускающих миграции базы данных
    #
    class Migration
      include Helpers::Log

      # Запускает миграцию
      #
      # @param [Sequel::Database] db
      #   база данных
      #
      # @param [Integer] to
      #   номер миграции, к которому необходимо привести базу данных. Если
      #   равен nil, то база данных приводится к последнему номеру.
      #
      # @param [Integer] from
      #   номер миграции, от которого будут применяться миграции к базе данных.
      #   Если равен nil, то в качестве значения берётся текущий номер миграции
      #   базы данных.
      #
      # @param [String] dir
      #   путь к директории, где будут искаться миграции
      #
      def self.launch!(db, to, from, dir)
        new(db, to, from, dir).launch!
      end

      # База данных
      #
      # @return [Sequel::Database]
      #   база данных
      #
      attr_reader :db

      # Номер миграции, к которому необходимо привести базу данных. Если равен
      # nil, то база данных приводится к последнему номеру.
      #
      # @return [Integer]
      #   номер миграции
      #
      attr_reader :to

      # Номер миграции, от которого будут применяться миграции к базе данных.
      # Если равен nil, то в качестве значения берётся текущий номер миграции
      # базы данных.
      #
      # @return [Integer]
      #   номер миграции
      #
      attr_reader :from

      # Путь к директории, где будут искаться миграции
      #
      # @return [String]
      #   путь к директории
      #
      attr_reader :dir

      # Инициализирует объект
      #
      # @param [Sequel::Database] db
      #   база данных
      #
      # @param [Integer] to
      #   номер миграции, к которому необходимо привести базу данных. Если
      #   равен nil, то база данных приводится к последнему номеру.
      #
      # @param [Integer] from
      #   номер миграции, от которого будут применяться миграции к базе данных.
      #   Если равен nil, то в качестве значения берётся текущий номер миграции
      #   базы данных.
      #
      # @param [String] dir
      #   путь к директории, где будут искаться миграции
      #
      def initialize(db, to, from, dir)
        @db = db
        @to = to
        @from = from
        @dir = dir
      end

      # Запускает миграцию
      #
      def launch!
        Sequel.extension :migration

        log_start

        current = from.nil? ? nil : from.to_i
        target = to.nil? ? nil : to.to_i
        Sequel::Migrator.run(db, dir, current: current, target: target)

        log_finish
      end

      # Создаёт записи в журнале событий о том, что начинается миграция базы
      # данных и какова эта миграция
      #
      def log_start
        log_info { <<~LOG }
          Начинается миграция базы данных #{db.opts[:database]}
        LOG

        log_info { <<~LOG }
          Исходная версия: #{from.nil? ? 'текущая' : from},
          целевая версия: #{to.nil? ? 'максимальная' : to}
        LOG
      end

      # Создаёт запись в журнале событий о том, что миграция базы данных
      # завершена
      #
      def log_finish
        log_info { <<~LOG }
          Миграция базы данных #{db.opts[:database]} завершена
        LOG
      end
    end
  end
end
