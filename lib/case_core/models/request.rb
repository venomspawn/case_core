# frozen_string_literal: true

module CaseCore
  module Models
    # Модель межведомственного запроса, связанного с заявкой
    # @!attribute id
    #   Идентификатор запроса
    #   @return [Integer]
    #     идентификатор запроса
    # @!attribute created_at
    #   Дата и время создания записи
    #   @return [Time]
    #     дата и время создания записи
    # @!attribute attributes
    #   Список записей атрибутов запроса
    #   @return [Array<CaseCore::Models::RequestAttribute>]
    #     список записей атрибутов запроса
    # @!attribute attributes_dataset
    #   Запрос на получение записей атрибутов запроса
    #   @return [Sequel::Dataset]
    #     запрос на получение записей атрибутов запроса
    # @!attribute case_id
    #   Идентификатор записи заявки, в рамках которой создан запрос
    #   @return [String]
    #     идентификатор записи заявки, в рамках которой создан запрос
    # @!attribute case
    #   Запись заявки, в рамках которой создан запрос
    #   @return [CaseCore::Models::Case]
    #     запись заявки, в рамках которой создан запрос
    class Request < Sequel::Model
      unrestrict_primary_key

      # Отношения
      one_to_many :attributes, class: 'CaseCore::Models::RequestAttribute'
      many_to_one :case
    end
  end
end
