# encoding: utf-8

module CaseCore
  module Models
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Модель связи между заявкой и реестром передаваемой корреспонденции
    #
    # @!attribute case_id
    #   Идентификатор записи заявки
    #
    #   @return [String]
    #     идентификатор записи заявки
    #
    #
    # @!attribute case
    #   Запись заявки
    #
    #   @return [CaseCore::Models::Case]
    #     запись заявки
    #
    #
    # @!attribute register_id
    #   Идентификатор записи реестра
    #
    #   @return [Integer]
    #     идентификатор записи реестра
    #
    #
    # @!attribute register
    #   Запись реестра
    #
    #   @return [CaseCore::Models::Register]
    #     запись реестра
    #
    class CaseRegister < Sequel::Model
      # Отношения
      many_to_one :case
      many_to_one :register

      # Создаёт запись модели
      #
      # @param [Hash] values
      #   атрибуты записи
      #
      # @return [CaseCore::Model::CaseAttribute]
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
