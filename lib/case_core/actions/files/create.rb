# frozen_string_literal: true

require 'securerandom'

module CaseCore
  module Actions
    module Files
      # Класс действий, создающих запись файла
      class Create
        # Инициализирует объект класса
        # @param [#read, #to_s] content
        #   содержимое, которое может быть представлено потоком или извлечено с
        #   помощью `#to_s`
        def initialize(content)
          @content = content
        end

        # Создаёт запись файла с предоставленным содержимым и возвращает
        # ассоциативный массив с информацией о записи
        # @return [Hash]
        #   результирующий ассоциативный массив
        def create
          record = create_file
          { id: record.id }
        end

        private

        # Содержимое, которое может быть представлено потоком или извлечено с
        # помощью `#to_s`
        # @return [#read, #to_s]
        #   содержимое, которое может быть представлено потоком или извлечено с
        #   помощью `#to_s`
        attr_reader :content

        # Создаёт запись файла и возвращает её
        # @return [CaseCore::Models::File]
        #   созданная запись файла
        def create_file
          model = Models::File
          model.unrestrict_primary_key
          model.create(attributes).tap { model.restrict_primary_key }
        end

        # Возвращает ассоциативный массив полей создаваемой записи
        # @return [Hash]
        #   ассоциативный массив полей создаваемой записи
        def attributes
          {
            id:         SecureRandom.uuid,
            content:    read_content,
            created_at: Time.now
          }
        end

        # Возвращает содержимое файла
        # @return [String]
        #   содержимое файла
        def read_content
          return content.to_s unless content.respond_to?(:read)
          content.rewind if content.respond_to?(:rewind)
          content.read.to_s
        end
      end
    end
  end
end
