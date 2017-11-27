# encoding: utf-8

module CaseCore
  # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
  #
  # Пространство имён для моделей сервиса
  #
  module Models
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Модель заявки
    #
    # @!attribute id
    #   Идентификатор записи
    #
    #   @return [String]
    #     идентификатор записи
    #
    #
    # @!attribute type
    #   Тип заявки
    #
    #   @return [String]
    #     тип заявки
    #
    #
    # @!attribute created_at
    #   Дата и время создания записи
    #
    #   @return [Time]
    #     дата и время создания записи
    #
    #
    # @!attribute attributes
    #   Список записей атрибутов заявки
    #
    #   @return [Array<CaseCore::Models::CaseAttribute>]
    #     список атрибутов записей заявки
    #
    #
    # @attribute attributes_dataset
    #   Запрос на получение записей атрибутов заявки
    #
    #   @return [Sequel::Dataset]
    #     запрос на получение записей атрибутов заявки
    #
    #
    # @attribute documents
    #   Список записей документов, прикреплённых к заявке
    #
    #   @return [Array<CaseCore::Models::Document>]
    #     список записей документов, прикреплённых к заявке
    #
    #
    # @attribute documents_dataset
    #   Запрос на получение записей документов, прикреплённых к заявке
    #
    #   @return [Sequel::Dataset]
    #     запрос на получение записей документов, прикреплённых к заявке
    #
    #
    # @attribute requests
    #   Список записей запросов, созданных в рамках заявки
    #
    #   @return [Array<CaseCore::Models::Request>]
    #     список записей запросов, созданных в рамках заявки
    #
    #
    # @attribute requests_dataset
    #   Запрос на получение записей запросов, созданных в рамках заявки
    #
    #   @return [Sequel::Dataset]
    #     запрос на получение записей запросов, созданных в рамках заявки
    #
    class Case < Sequel::Model
      # Отношения
      one_to_many :attributes, class: 'CaseCore::Models::CaseAttribute'
      one_to_many :documents
      one_to_many :requests

      # Создаёт запись модели
      #
      # @param [Hash] values
      #   атрибуты записи
      #
      # @return [CaseCore::Model::Case]
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
