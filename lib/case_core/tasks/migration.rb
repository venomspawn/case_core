# frozen_string_literal: true

module CaseCore
  need 'helpers/log'

  # Пространство имён классов объектов, обслуживающих Rake-задачи
  module Tasks
    # Класс объектов, запускающих миграции базы данных
    class Migration
      include Helpers::Log

      # Запускает миграцию
      # @param [Integer] to
      #   номер миграции, к которому необходимо привести базу данных. Если
      #   равен nil, то база данных приводится к последнему номеру.
      # @param [Integer] from
      #   номер миграции, от которого будут применяться миграции к базе данных.
      #   Если равен nil, то в качестве значения берётся текущий номер миграции
      #   базы данных.
      def self.launch!(to, from)
        new(to, from).launch!
      end

      # Номер миграции, к которому необходимо привести базу данных. Если равен
      # nil, то база данных приводится к последнему номеру.
      # @return [Integer]
      #   номер миграции
      attr_reader :to

      # Номер миграции, от которого будут применяться миграции к базе данных.
      # Если равен nil, то в качестве значения берётся текущий номер миграции
      # базы данных.
      # @return [Integer]
      #   номер миграции
      attr_reader :from

      # Инициализирует объект
      # @param [Integer] to
      #   номер миграции, к которому необходимо привести базу данных. Если
      #   равен nil, то база данных приводится к последнему номеру.
      # @param [Integer] from
      #   номер миграции, от которого будут применяться миграции к базе данных.
      #   Если равен nil, то в качестве значения берётся текущий номер миграции
      #   базы данных.
      def initialize(to, from)
        @to = to
        @from = from
      end

      # Запускает миграцию
      def launch!
        Sequel.extension :migration

        log_start

        database = Sequel::Model.db
        dir = "#{CaseCore.root}/db/migrations"
        current = from.nil? ? nil : from.to_i
        target = to.nil? ? nil : to.to_i
        Sequel::Migrator.run(database, dir, current: current, target: target)

        log_finish
      end

      private

      # Возвращает название базы данных
      # @return [#to_s]
      #   название базы данных
      def db_name
        Sequel::Model.db.opts[:database]
      end

      # Создаёт записи в журнале событий о том, что начинается миграция базы
      # данных и какова эта миграция
      def log_start
        log_info { "Начинается миграция базы данных #{db_name}" }
        log_info { "Исходная версия: #{from.nil? ? 'текущая' : from}" }
        log_info { "Целевая версия: #{to.nil? ? 'максимальная' : to}" }
      end

      # Создаёт запись в журнале событий о том, что миграция базы данных
      # завершена
      def log_finish
        log_info { "Миграция базы данных #{db_name} завершена" }
      end
    end
  end
end
