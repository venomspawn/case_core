# frozen_string_literal: true

module CaseCore
  module Models
    # Модель атрибута межведомственного запроса
    # @!attribute request_id
    #   Идентификатор записи межведомственного запроса
    #   @return [Integer]
    #     идентификатор записи межведомственного запроса
    # @!attribute request
    #   Запись межведомственного запроса
    #   @return [CaseCore::Models::Request]
    #     запись межведомственного запроса
    # @!attribute name
    #   Название атрибута
    #   @return [String]
    #     название атрибута
    # @!attribute value
    #   Значение атрибута
    #   @return [String]
    #     значение атрибута
    class RequestAttribute < Sequel::Model
      unrestrict_primary_key

      # Отношения
      many_to_one :request
    end
  end
end
