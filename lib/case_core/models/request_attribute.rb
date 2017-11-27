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
    # @!attribute request
    #   Запись межведомственного запроса
    #
    #   @return [CaseCore::Models::Request]
    #     запись межведомственного запроса
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

      # Обновляет запись модели
      #
      # @param [Hash] values
      #   новые атрибуты записи
      #
      # @return [Boolean]
      #   удалось или нет сохранить запись
      #
      def update(values)
        model.restrict_primary_key unless model.restrict_primary_key?
        super
      end
    end
  end
end
