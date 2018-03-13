# frozen_string_literal: true

require_relative 'log/prefix'

module CaseCore
  # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
  #
  # Пространство имён для модулей, включаемых в классы
  #
  module Helpers
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Модуль для включения поддержки журнала событий. Является оболочкой над
    # объектом класса `Logger`.
    #
    module Log
      private

      # Возвращает журнал событий
      #
      # @return [Logger]
      #   журнал событий
      #
      def logger
        $logger
      end

      # Создаёт запись в журнале событий с данным уровнем значимости
      #
      # @param [Integer] level
      #   уровень значимости записи
      #
      # @param [Binding] context
      #   контекст, из которого извлекается информация о вызвавшем методе
      #
      # @yield [String]
      #   сообщение
      #
      def log_with_level(level, context = nil)
        return unless logger.is_a?(Logger)

        logger.log(level) do
          prefix = Prefix.new(context).prefix
          message = adjusted_message(yield)
          [prefix, message].find_all(&:present?).join(' ')
        end

        nil
      end

      # Создаёт запись в журнале событий с уровнем значимости DEBUG
      #
      # @param [Binding] context
      #   контекст, из которого извлекается информация о вызвавшем методе
      #
      # @yield [String]
      #   сообщение
      #
      def log_debug(context = nil, &block)
        log_with_level(Logger::DEBUG, context, &block)
      end

      # Создаёт запись в журнале событий с уровнем значимости INFO
      #
      # @param [Binding] context
      #   контекст, из которого извлекается информация о вызвавшем методе
      #
      # @yield [String]
      #   сообщение
      #
      def log_info(context = nil, &block)
        log_with_level(Logger::INFO, context, &block)
      end

      # Создаёт запись в журнале событий с уровнем значимости WARN
      #
      # @param [Binding] context
      #   контекст, из которого извлекается информация о вызвавшем методе
      #
      # @yield [String]
      #   сообщение
      #
      def log_warn(context = nil, &block)
        log_with_level(Logger::WARN, context, &block)
      end

      # Создаёт запись в журнале событий с уровнем значимости ERROR
      #
      # @param [Binding] context
      #   контекст, из которого извлекается информация о вызвавшем методе
      #
      # @yield [String]
      #   сообщение
      #
      def log_error(context = nil, &block)
        log_with_level(Logger::ERROR, context, &block)
      end

      # Создаёт запись в журнале событий с уровнем значимости UNKNOWN
      #
      # @param [Binding] context
      #   контекст, из которого извлекается информация о вызвавшем методе
      #
      # @yield [String]
      #   сообщение
      #
      def log_unknown(context = nil, &block)
        log_with_level(Logger::UNKNOWN, context, &block)
      end

      # Возвращает корректную строку в кодировке UTF-8, построенную на основе
      # строкового представления аргумента
      #
      # @param [#to_s] obj
      #   аргумент
      #
      # @return [String]
      #   результирующая строка
      #
      def repaired_string(obj)
        str = obj.to_s
        return str if str.encoding == Encoding::UTF_8 && str.valid_encoding?
        str = str.dup if str.frozen?
        str.force_encoding(Encoding::UTF_8)
        return str if str.valid_encoding?
        str.force_encoding(Encoding::ASCII_8BIT)
        str.encode(Encoding::UTF_8, undef: :replace, invalid: :replace)
      end

      # Возвращает обработанный текст сообщения
      #
      # @param [#to_s] message
      #   сообщение
      #
      # @return [String]
      #   обработанный текст сообщения
      #
      def adjusted_message(message)
        repaired_string(message).squish
      end
    end
  end
end
