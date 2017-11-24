# encoding: utf-8

module CaseCore
  module Models
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Модель межведомственного запроса, связанного с заявкой
    #
    # @!attribute id
    #   Идентификатор запроса
    #
    #   @return [Integer]
    #     идентификатор запроса
    #
    #
    # @!attribute created_at
    #   Дата и время создания записи
    #
    #   @return [Time]
    #     дата и время создания записи
    #
    class Request < Sequel::Model
      # Отношения
      one_to_many :attributes, class: 'CaseCore::Models::RequestAttribute'
      many_to_one :case

      # Создаёт запись модели
      #
      # @param [Hash] values
      #   атрибуты записи
      #
      # @return [CaseCore::Model::Request]
      #   созданная запись модели
      #
      def self.create(values)
        unrestrict_primary_key
        super.tap { restrict_primary_key }
      end
    end
  end
end
