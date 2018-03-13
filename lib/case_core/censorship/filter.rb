# frozen_string_literal: true

require "#{$lib}/settings/configurable"

require_relative 'filter/settings'

module CaseCore
  # Пространство имён для классов, предоставляющих функции фильтрации значений
  # ключей ассоциативных массивов
  module Censorship
    # Класс, предоставляющий методы и функции фильтрации значений ключей
    # ассоциативных массивов
    class Filter
      extend CaseCore::Settings::Configurable

      @settings_class = Settings

      # Создаёт объект класса и возвращает результат вызова метода `process`
      # созданного объекта
      # @param [Object] obj
      #   аргумент
      # @return [Object]
      #   результирующий объект
      def self.process(obj)
        new.process(obj)
      end

      # Возвращает значения в зависимости от типа аргумента.
      #
      # *   Если типом аргумента является ассоциативный массив (Hash), то
      #     возвращает новый ассоциативный массив, значения ключей которого
      #     заменены на строку, заданную в настройке `censored_message`, если
      #     эти ключи должны быть отфильтрованы; значения тех ключей, которые
      #     не подлежат фильтрации, заменяются на результаты вызова метода
      #     `process`.
      # *   Если типом аргумента является список (Array), то применяет к его
      #     элементам этот же метод и возвращает новый список на основе
      #     значений операции.
      # *   Если типом аргумента является строка (String), то
      #     -   пытается интерпретировать её как JSON-представление объекта и
      #         восстановить этот объект, к которому затем применяет этот же
      #         метод {process}, и возвращает JSON-представление результата
      #         метода;
      #     -   в случае, если строку невозможно интепретировать как
      #         JSON-представление объекто, проверяет, есть ли ограничение на
      #         длину строки (настройка `string_length_limit`); если
      #         ограничение присутствует, а длина строки больше ограничения, то
      #         заменяет её строкой, заданной в настройке `too_long_message`.
      # *   Во всех остальных случаях возвращает исходный объект.
      # @param [Object] obj
      #   аргумент
      # @return [Object]
      #   результирующий объект
      def process(obj)
        return process_hash(obj)   if obj.is_a?(Hash)
        return process_array(obj)  if obj.is_a?(Array)
        return process_string(obj) if obj.is_a?(String)
        obj
      end

      alias censor process

      private

      # Возвращает новый ассоциативный массив, значения ключей которого
      # заменены на строку, заданную в настройке `censored_message`, если эти
      # ключи должны быть отфильтрованы; значения тех ключей, которые не
      # подлежат фильтрации, заменяются на результаты вызова метода `process`
      # @param [Hash] hash
      #   исходный ассоциативный массив
      # @return [Hash]
      #   результирующий ассоциативный массив
      def process_hash(hash)
        filters = Filter.settings.filters
        hash.each_with_object({}) do |(key, value), memo|
          key = key.to_sym
          processed = filters.include?(key)
          value = processed ? censored_message : process(value)
          memo[key] = value
        end
      end

      # Применяет к элементам исходного списка метод {process} и возвращает
      # новый список на основе возвращённых значений
      # @param [Array] array
      #   исходный список
      # @return [Array]
      #   результирующий список
      def process_array(array)
        array.map(&method(:process))
      end

      # Пытается интерпретировать аргумент как JSON-представление объекта и
      # восстановить этот объект, к которому затем применяет метод {process},
      # и возвращает JSON-представление результата метода. В случае, если
      # строку невозможно интепретировать как JSON-представление объекто,
      # проверяет, есть ли ограничение на длину строки (настройка
      # `string_length_limit`); если ограничение присутствует, а длина строки
      # больше ограничения, то возвращает строку, заданную в настройке
      # `too_long_message`; в противном случае возвращает исходную строку.
      # @param [String] string
      #   исходная строка
      # @return [String]
      #   результирующая строка
      def process_string(string)
        process(JSON.parse(string, symbolize_names: true)).to_json
      rescue JSON::ParserError
        too_long?(string) ? too_long_message : string
      end

      # Возвращает строку с сообщением о том, что значение ключа ассоциативного
      # массива не может быть показано
      # @return [String]
      #   строка с сообщением о том, что значение ключа ассоциативного
      #   массива не может быть показано
      def censored_message
        @censored_message ||= Filter.settings.censored_message.to_s
      end

      # Возвращает строку с сообщением о том, что строка имеет слишком большую
      # длину
      # @return [#to_s]
      #   строка с сообщением о том, что строка имеет слишком большую длину
      def too_long_message
        @too_long_message ||= Filter.settings.too_long_message.to_s
      end

      # Возвращает максимальную длину строки для отображения или `nil`, если
      # нет ограничения на максимальную длину
      # @return [NilClass, Integer]
      #   максимальная длина строки для отображения или `nil`, если нет
      #   ограничения на максимальную длину
      def string_length_limit
        Filter.settings.string_length_limit
      end

      # Возвращает, есть ли ограничение на максимальную длину строки для
      # отображения
      # @return [Boolean]
      #   есть ли ограничение на максимальную длину строки для отображения
      def string_length_limit?
        !string_length_limit.nil?
      end

      # Возвращает, выходит ли длина строки за ограничение на максмальную длину
      # строки для отображения в случае, если это ограничение присутствует.
      # Возвращает ложь, если ограничение на максимальную длину строки
      # отсутствует.
      # @return [Boolean]
      #   результирующее значение
      def too_long?(string)
        string_length_limit? && string_length_limit < string.length
      end
    end
  end
end
