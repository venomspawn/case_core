# frozen_string_literal: true

module CaseCore
  module Models
    # Модель файла
    # @!attribute id
    #   Идентификатор записи
    #   @return [String]
    #     идентификатор записи
    # @!attribute content
    #   Содержимое файла
    #   @return [String]
    #     содержимое файла
    # @!attribute created_at
    #   Дата и время создания записи
    #   @return [Time]
    #     дата и время создания записи
    class File < Sequel::Model
    end
  end
end
