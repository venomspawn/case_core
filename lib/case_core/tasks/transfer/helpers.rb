# frozen_string_literal: true

require 'securerandom'

module CaseCore
  need 'helpers/log'

  module Tasks
    class Transfer
      # Вспомогательный модуль, предназначенный для подключения к содержащему
      # классу
      module Helpers
        include CaseCore::Helpers::Log

        # Создаёт запись в журнале событий о том, что импортированы записи
        # заявок
        # @param [Integer] count
        #   количество импортированных записей заявок
        # @param [Binding] context
        #   контекст
        def log_imported_cases(count, context)
          log_info(context) { <<-MESSAGE }
            Импортированы записи заявок в количестве #{count}
          MESSAGE
        end

        # Создаёт запись в журнале событий о том, что импортированы атрибуты
        # заявок
        # @param [Integer] count
        #   количество импортированных атрибутов заявок
        # @param [Binding] context
        #   контекст
        def log_imported_case_attributes(count, context)
          log_info(context) { <<-MESSAGE }
            Импортированы атрибуты заявок в количестве #{count}
          MESSAGE
          Transfer.stats.keys.sort.each do |name|
            log_debug(context) { "#{name}: #{Transfer.stats[name]}" }
          end
          Transfer.stats.select { |_, v| v.zero? }.keys.sort.each do |name|
            log_debug(context) { "#{name}: zero" }
          end
        end

        # Создаёт запись в журнале событий о том, что импортированы записи
        # документов
        # @param [Integer] count
        #   количество импортированных записей документов
        # @param [Binding] context
        #   контекст
        def log_imported_documents(count, context)
          log_info(context) { <<-MESSAGE }
            Импортированы записи документов в количестве #{count}
          MESSAGE
        end

        # Создаёт запись в журнале событий о том, что импортированы записи
        # межведомственных запросов
        # @param [Integer] count
        #   количество импортированных записей межведомственных запросов
        # @param [Binding] context
        #   контекст
        def log_imported_requests(count, context)
          log_info(context) { <<-MESSAGE }
            Импортированы записи межведомственных запросов в количестве
            #{count}
          MESSAGE
        end

        # Создаёт запись в журнале событий о том, что импортированы атрибуты
        # межведомственных запросов
        # @param [Integer] count
        #   количество импортированных атрибутов межведомственных запросов
        # @param [Binding] context
        #   контекст
        def log_imported_request_attributes(count, context)
          log_info(context) { <<-MESSAGE }
            Импортированы атрибуты межведомственных запросов в количестве
            #{count}
          MESSAGE
        end

        # Создаёт запись в журнале событий о том, что импортированы реестры
        # передаваемой корреспонденции
        # @param [Integer] count
        #   количество импортированных реестров
        # @param [Binding] context
        #   контекст
        def log_imported_registers(count, context)
          log_info(context) { <<-MESSAGE }
            Импортированы реестры передаваемой корреспонденции в количестве
            #{count}
          MESSAGE
        end

        # Создаёт запись в журнале событий о результате извлечения тела файла
        # из файлового хранилища
        # @param [String] fs_id
        #   идентификатор файла
        # @param [String] content
        #   тело файла
        def log_file_content(fs_id, content)
          content.nil? ? log_warn { <<-ERROR } : log_info { <<-SUCCESS }
            Не удалось скачать файл с идентификатором #{fs_id}
          ERROR
            Файл с идентификатором #{fs_id} успешно скачан, количество байт —
            #{content.size}
          SUCCESS
        end

        # Регулярное выражение для отбрасывания символов, не являющихся
        # шестнадцатеричными символами
        NOT_HEX = /[^a-fA-F0-9]/

        # Длина строки с шестнадцатеричным представлением UUID
        UUID_SIZE = 32

        # Диапазон для отсекания лишних символов
        TAIL = (UUID_SIZE..-1).freeze

        # Диапазоны для выделения частей текстового представления UUID
        RANGES = [0..7, 8..11, 12..15, 16..19, 20..31].freeze

        # Разделителей частей в текстовом представлении UUID
        DELIMITER = '-'

        # Возвращает текстовое представление UUID, созданное на основе
        # предоставленной строки
        # @param [String] fs_id
        #   предоставленная строка
        # @return [String]
        #   результирующее текстовое представление UUID
        def extract_fs_id(fs_id)
          fs_id.gsub!(NOT_HEX, '')
          fs_id << SecureRandom.hex(UUID_SIZE)
          fs_id.slice!(TAIL)
          RANGES.map(&fs_id.method(:[])).join(DELIMITER)
        end
      end
    end
  end
end
