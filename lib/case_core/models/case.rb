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
    #   Идентификатор карточки
    #
    #   @return [Integer]
    #     идентификатор карточки
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
    class Case < Sequel::Model
      # Отношения
      one_to_many :attributes, class: 'CaseCore::Models::CaseAttribute'
    end
  end
end
