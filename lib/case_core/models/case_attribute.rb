# encoding: utf-8

module CaseCore
  module Models
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Модель атрибута заявки
    #
    # @!attribute case_id
    #   Идентификатор карточки
    #
    #   @return [Integer]
    #     идентификатор карточки
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
    class CaseAttribute < Sequel::Model
      # Отношения
      many_to_one :case

      unrestrict_primary_key
    end
  end
end
