# frozen_string_literal: true

module CaseCore
  need 'settings/mixin'

  module Censorship
    class Filter
      # Класс настроек фильтрации ключей ассоциативных массивов и строк
      class Settings
        include CaseCore::Settings::Mixin

        # Строка с сообщением о том, что значение ключа ассоциативного массива
        # не может быть показано
        # @return [#to_s]
        #   строка с сообщением о том, что значение ключа ассоциативного
        #   массива не может быть показано
        attr_accessor :censored_message

        # Строка с сообщением о том, что строка имеет слишком большую длину
        # @return [#to_s]
        #   строка с сообщением о том, что строка имеет слишком большую длину
        attr_accessor :too_long_message

        # Максимальная длина строки для отображения или `nil`, если нет
        # ограничения на максимальную длину
        # @return [NilClass, Integer]
        #   максимальная длина строки для отображения или `nil`, если нет
        #   ограничения на максимальную длину
        attr_reader :string_length_limit

        # Устанавливает или снимает ограничение на максимальную длину строки
        # для отображения. Ограничение устанавливается в том и только в том
        # случае, если аргумент приводится к натуральному числу либо через
        # вызов метода `#to_int` для числовых типов, либо через приведение к
        # строке через метод `#to_s` и приведение к натуральному числу через
        # метод `#to_i`.
        # @param [Object] limit
        #   аргумент
        # @return [NilClass]
        #   если ограничение на максимальную длину строки снято
        # @return [Object]
        #   аргумент
        def string_length_limit=(limit)
          if limit.nil?
            @string_length_limit = nil
          elsif limit.is_a?(Numeric)
            limit = limit.to_int
            @string_length_limit = limit.positive? ? limit : nil
          else
            self.string_length_limit = limit.to_s.to_i
          end
        end

        # Возвращает список фильтруемых ключей
        # @return [Array<Symbol>]
        #   список фильтруемых ключей
        def filters
          @filters ||= []
        end

        # Устанавливает список фильтруемых ключей
        # @param [Enumerable<#to_sym>] filters
        #   коллекция фильтруемых ключей
        def filters=(filters)
          @filters = filters.map(&:to_sym)
        end

        # Добавляет аргументы в список фильтруемых ключей
        # @param [Array<#to_sym>] args
        #   список аргументов
        def filter(*args)
          args.each { |arg| filters << arg.to_sym }
        end
      end
    end
  end
end
