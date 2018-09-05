# frozen_string_literal: true

module CaseCore
  need 'helpers/log'

  # Пространство имён классов объектов, осуществляющих удаление записей файлов,
  # на которые не ссылается ни одна запись электронных копий документов
  module DFC
    # Класс объектов, осуществляющих удаление записей файлов, на которые не
    # ссылается ни одна запись электронных копий документов
    class Sweep
      include Helpers::Log

      # Извлекает записи файлов по следующему критерию:
      #
      # *   на запись файла не ссылается ни одна запись электронных копий
      #     документов;
      # *   метка времени создания записи файла отстоит от текущего времени
      #     более, чем на предоставленное количество секунд.
      # Удаляет записи файлов после извлечения.
      # @param [Integer] death_age
      #   минимальное количество секунд с момента создания удаляемой записи
      #   файла до текущего времени
      def self.invoke(death_age)
        new(death_age).invoke
      end

      # Инициализирует объект класса
      # @param [Integer] death_age
      #   минимальное количество секунд с момента создания удаляемой записи
      #   файла до текущего времени
      def initialize(death_age)
        @death_age = death_age
      end

      # Извлекает записи файлов по следующему критерию:
      #
      # *   на запись файла не ссылается ни одна запись электронных копий
      #     документов;
      # *   метка времени создания записи файла отстоит от текущего времени
      #     более, чем на предоставленное количество секунд.
      # Удаляет записи файлов после извлечения.
      def invoke
        log_start(binding)
        log_files(files, binding)
        Sequel::Model.db[:files].where(id: file_ids).delete unless files.empty?
        log_finish(binding)
      end

      private

      # Минимальное количество секунд с момента создания удаляемой записи файла
      # до текущего времени
      # @return [Integer]
      #   минимальное количество секунд с момента создания удаляемой записи
      #   файла до текущего времени
      attr_reader :death_age

      # Запрос Sequel на извлечение идентификаторов записей файлов, на которые
      # ссылаются электронные копии документов
      FS_IDS_DATASET = Sequel::Model.db[:scans].select(:fs_id)

      # Выражение для извлечения метки времени создания записи файла
      CREATED_AT =
        :to_char
        .sql_function(:created_at, 'DD.MM.YYYY HH24:MI:SS')
        .as(:created_at)

      # Запрос Sequel на извлечение записей файлов, на которые не ссылается ни
      # одна запись документа
      FILES_DATASET =
        Sequel::Model
        .db[:files]
        .select(:id, CREATED_AT)
        .exclude(id: FS_IDS_DATASET)

      # Возвращает список ассоциативных массивов с информацией о записях
      # файлов, на которые не ссылается ни одна запись документа
      # @return [Array<Hash>]
      #   результирующий список
      def files
        @files ||= FILES_DATASET.where(created_at_condition).to_a
      end

      # Возвращает строковое представление даты и времени, отстоящей от
      # текущего времени на {death_age} секунд в прошлое
      # @return [String]
      #   результирующее строковое представление
      def max_created_at
        max = Time.now - death_age
        max.strftime('%FT%T')
      end

      # Возвращает выражение Sequel для извлечения записей файлов, созданных не
      # позже, чем дата и время, возвращаемые {max_created_at}
      def created_at_condition
        Sequel.lit("\"created_at\" <= '#{max_created_at}'::timestamp")
      end

      # Возвращает список идентификаторов записей файлов, на которые не
      # ссылается ни одна запись электронных копий документов
      # @return [Array<String>]
      #   результирующий список
      def file_ids
        files.map { |file| file[:id] }
      end

      # Сообщение о начале работы
      LOG_START = <<-LOG.squish.freeze
        Начинается проверка на наличие записей файлов, на которые не ссылается
        ни одна запись электронных копий документов, а также удаление этих
        записей
      LOG

      # Создаёт новую запись в журнале событий о том, что начинается проверка
      # на наличие записей файлов, на которые не ссылается ни одна запись
      # электронных копий документов, а также удаление этих записей
      # @param [Binding] context
      #   контекст
      def log_start(context)
        log_info(context) { LOG_START }
      end

      # Сообщение об окончании работы
      LOG_FINISH = <<-LOG.squish.freeze
        Проверка на наличие записей файлов, на которые не ссылается ни одна
        запись электронных копий документов, и удаление этих записей завершены
      LOG

      # Создаёт новую запись в журнале событий о том, что проверка на наличие
      # записей файлов, на которые не ссылается ни одна запись электронных
      # копий документов, и удаление этих записей завершены
      # @param [Binding] context
      #   контекст
      def log_finish(context)
        log_info(context) { LOG_FINISH }
      end

      # Сообщение о том, что записи файлов, на которые не ссылается ни одна
      # запись электронных копий документов, не найдены
      LOG_NO_FILES = 'Искомые записи файлов не найдены'

      # Создаёт одну или несколько новых записей в журнале событий в
      # зависимости от того, найдены ли искомые записи файлов или нет
      # @param [Array<Hash>] files
      #   список ассоциативных массивов с информацией о записях файлов
      # @param [Binding] context
      #   контекст
      def log_files(files, context)
        return log_info { LOG_NO_FILES } if files.empty?
        files.each do |file|
          log_warn(context) { <<-LOG }
            Будет удалена запись файла с идентификатором `#{file[:id]}`,
            которая была создана `#{file[:created_at]}`
          LOG
        end
      end
    end
  end
end
