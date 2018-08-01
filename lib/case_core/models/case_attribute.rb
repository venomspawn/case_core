# frozen_string_literal: true

module CaseCore
  module Models
    # Модель атрибута заявки
    # @!attribute case_id
    #   Идентификатор записи заявки
    #   @return [String]
    #     идентификатор записи заявки
    # @!attribute case
    #   Запись заявки
    #   @return [CaseCore::Models::Case]
    #     запись заявки
    # @!attribute name
    #   Название атрибута
    #   @return [String]
    #     название атрибута
    # @!attribute value
    #   Значение атрибута
    #   @return [String]
    #     значение атрибута
    class CaseAttribute < Sequel::Model
      unrestrict_primary_key

      # Отношения
      many_to_one :case
    end
  end
end
