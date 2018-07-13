# frozen_string_literal: true

module CaseCore
  need 'actions/base/action'

  module Actions
    module Files
      # Класс действий, обновляющих содержимое файла
      class Update < Base::Action
        require_relative 'update/params_schema'

        # Обновляет содержимое файла
        # @raise [Sequel::NoMatchingRow]
        #   если запись файла невозможно найти
        def update
          record.update(content: read_content)
        end

        private

        # Возвращает значение атрибута `id` ассоциативного массива параметров
        # @return [Object]
        #   результирующее значение
        def id
          params[:id]
        end

        # Возвращает значение атрибута `content` ассоциативного массива
        # параметров
        # @return [Object]
        #   результирующее значение
        def content
          params[:content]
        end

        # Возвращает запись файла
        # @return [CaseCore::Models::File]
        #   запись файла
        # @raise [Sequel::NoMatchingRow]
        #   если запись файла невозможно найти
        def record
          Models::File.select(:id).with_pk!(id)
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
