# frozen_string_literal: true

module CaseCore
  module Models
    # Модель документа, прикреплённого к заявке
    # @!attribute id
    #   Идентификатор записи
    #   @return [String]
    #     идентификатор записи
    # @!attribute title
    #   Заголовок документа
    #   @return [String]
    #     заголовок документа
    #   @return [NilClass]
    #     если заголовок документа отсутствует
    # @!attribute case_id
    #   Идентификатор записи заявки, к которой прикреплён документ
    #   @return [String]
    #     идентификатор записи заявки, к которой прикреплён документ
    # @!attribute scan_id
    #   Идентификатор записи электронной копии документа
    #   @return [String]
    #     идентификатор записи электронной копии документа
    # @!attribute case
    #   Запись заявки, к которой прикреплён документ
    #   @return [CaseCore::Models::Case]
    #     запись заявки, к которой прикреплён документ
    class Document < Sequel::Model
      unrestrict_primary_key

      # Отношения
      many_to_one :case
    end
  end
end
