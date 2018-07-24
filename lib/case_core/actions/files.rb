# frozen_string_literal: true

module CaseCore
  module Actions
    # Пространство имён классов действий, оперирующих файлами
    module Files
      require_relative 'files/create'

      # Создаёт запись файла с предоставленным содержимым и возвращает
      # ассоциативный массив с информацией о записи
      # @param [#read, #to_s] content
      #   содержимое, которое может быть представлено потоком или извлечено с
      #   помощью `#to_s`
      # @return [Hash]
      #   результирующий ассоциативный массив
      def self.create(content)
        Create.new(content).create
      end

      require_relative 'files/show'

      # Возвращает содержимое файла
      # @param [Object] params
      #   параметры действия
      # @param [NilClass, Hash] rest
      #   ассоциативный массив дополнительных параметров действия или `nil`,
      #   если дополнительные параметры отсутствуют
      # @return [String]
      #   содержимое файла
      # @raise [Sequel::NoMatchingRow]
      #   если запись файла не найдена по предоставленному идентификатору
      def self.show(params, rest = nil)
        Show.new(params, rest).show
      end

      require_relative 'files/update'

      # Обновляет содержимое файла
      # @param [Object] params
      #   параметры действия
      # @param [NilClass, Hash] rest
      #   ассоциативный массив дополнительных параметров действия или `nil`,
      #   если дополнительные параметры отсутствуют
      # @raise [Sequel::NoMatchingRow]
      #   если запись файла не найдена по предоставленному идентификатору
      def self.update(params, rest = nil)
        Update.new(params, rest).update
      end
    end
  end
end
