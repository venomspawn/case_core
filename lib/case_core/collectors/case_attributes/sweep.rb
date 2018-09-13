# frozen_string_literal: true

module CaseCore
  need 'helpers/log'

  module Collectors
    # Пространство имён классов объектов, осуществляющих удаление записей
    # атрибутов заявок со значением `nil`
    module CaseAttributes
      # Класс объектов, осуществляющих удаление записей атрибутов заявок со
      # значением `nil`
      class Sweep
        include Helpers::Log

        # Удаляет записи атрибутов заявок со значением `nil`
        def self.invoke
          new.invoke
        end

        # Удаляет записи атрибутов заявок со значением `nil`
        def invoke
          log_start(binding)
          deleted = delete_case_attributes # nodoc
          log_finish(deleted, binding)
        end

        private

        # Запрос Sequel на извлечение записей атрибутов заявок со значением
        # `nil`
        DATASET = Sequel::Model.db[:case_attributes].where(value: nil)

        # Удаляет записи атрибутов заявок со значением `nil` и возвращает
        # количество удалённых записей
        def delete_case_attributes
          DATASET.delete
        end

        # Сообщение о начале работы
        LOG_START = <<-LOG.squish.freeze
          Начинается удаление записей атрибутов заявок со значением `nil`
        LOG

        # Создаёт новую запись в журнале событий о том, что начинается удаление
        # записей атрибутов заявок со значением `nil`
        # @param [Binding] context
        #   контекст
        def log_start(context)
          log_info(context) { LOG_START }
        end

        # Сообщение об окончании работы
        LOG_FINISH = <<-LOG.squish.freeze
          Удаление записей атрибутов заявок со значением `nil` завершено,
          удалены записи в количестве %d
        LOG

        # Создаёт новую запись в журнале событий о том, что удаление записей
        # атрибутов заявок со значением `nil` завершено
        # @param [Integer] deleted
        #   количество удалённых записей
        # @param [Binding] context
        #   контекст
        def log_finish(deleted, context)
          log_info(context) { format(LOG_FINISH, deleted) }
        end
      end
    end
  end
end
