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
      # Отношения
      many_to_one :case

      # Создаёт запись модели
      # @param [Hash] values
      #   атрибуты записи
      # @return [CaseCore::Model::CaseAttribute]
      #   созданная запись модели
      def self.create(values)
        unrestrict_primary_key
        super.tap { restrict_primary_key }
      end

      # Обновляет запись модели
      # @param [Hash] values
      #   новые атрибуты записи
      # @return [Boolean]
      #   удалось или нет сохранить запись
      def update(values)
        model.restrict_primary_key unless model.restrict_primary_key?
        super
      end
    end
  end
end
