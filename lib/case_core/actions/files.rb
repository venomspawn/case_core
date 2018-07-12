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
    end
  end
end
