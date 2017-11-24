# encoding: utf-8

module CaseCore
  module Models
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Модель атрибута межведомственного запроса
    #
    # @!attribute request_id
    #   Идентификатор записи межведомственного запроса
    #
    #   @return [Integer]
    #     идентификатор записи межведомственного запроса
    #
    #
    # @!attribute name
    #   Название атрибута
    #
    #   @return [String]
    #     название атрибута
    #
    #
    # @!attribute value
    #   Значение атрибута
    #
    #   @return [String]
    #     значение атрибута
    #
    class RequestAttribute < Sequel::Model
      # Отношения
      many_to_one :request

      # Создаёт запись модели
      #
      # @param [Hash] values
      #   атрибуты записи
      #
      # @return [CaseCore::Model::RequestAttribute]
      #   созданная запись модели
      #
      def self.create(values)
        unrestrict_primary_key
        super.tap { restrict_primary_key }
      end
    end
  end
end
