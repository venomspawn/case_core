# frozen_string_literal: true

module CaseCore
  need 'actions/base/action'

  module Actions
    module Documents
      # Класс действий над записями документов, предоставляющий метод `index`,
      # который возвращает список ассоциативных массивов атрибутов документов,
      # прикреплённых к заявке
      class Index < Base::Action
        require_relative 'index/params_schema'

        # Возвращает список ассоциативных массивов атрибутов документов,
        # прикреплённых к заявке
        # @return [Array<Hash>]
        #   список ассоциативных массивов атрибутов документов, прикреплённых к
        #   заявке
        def index
          documents_dataset.to_a
        end

        private

        # Возвращает запись заявки
        # @return [CaseCore::Models::Case]
        #   запись заявки
        # @raise [Sequel::NoMatchingRow]
        #   если запись заявки не найдена
        def record
          @record ||= CaseCore::Models::Case.with_pk!(id)
        end

        # Возвращает значение атрибута `id` ассоциативного массива параметров
        # @return [Object]
        #   результирующее значение
        def id
          params[:id]
        end

        # Полное название поля `documents.id`
        ID = :id.qualify(:documents)

        # Полное название поля `documents.case_id`
        CASE_ID = :case_id.qualify(:documents)

        # Полное название поля `documents.title`
        TITLE = :title.qualify(:documents)

        # Полное название поля `documents.scan_id`
        SCAN_ID = :scan_id.qualify(:documents)

        # Полное название поля `scans.direction`
        DIRECTION = :direction.qualify(:scans)

        # Полное название поля `scans.correct`
        CORRECT = :correct.qualify(:scans)

        # Полное название поля `scans.provided_as`
        PROVIDED_AS = :provided_as.qualify(:scans)

        # Полное название поля `scans.size`
        SIZE = :size.qualify(:scans)

        # Полное название поля `scans.last_modified`
        LAST_MODIFIED = :last_modified.qualify(:scans)

        # Полное название поля `scans.quantity`
        QUANTITY = :quantity.qualify(:scans)

        # Полное название поля `scans.mime_type`
        MIME_TYPE = :mime_type.qualify(:scans)

        # Полное название поля `scans.filename`
        FILENAME = :filename.qualify(:scans)

        # Выражение для извлечения атрибута `provided`
        PROVIDED = (~{ SCAN_ID => nil }).as(:provided)

        # Полное название поля `scans.in_document_id`
        IN_DOCUMENT_ID = :in_document_id.qualify(:scans)

        # Полное название поля `scans.fs_id`
        FS_ID = :fs_id.qualify(:scans)

        # Полное название поля `scans.created_at`
        CREATED_AT = :created_at.qualify(:scans)

        # Список выражений для извлечения информации о документах
        COLUMNS = [
          ID,
          CASE_ID,
          TITLE,
          DIRECTION,
          CORRECT,
          PROVIDED_AS,
          SIZE,
          LAST_MODIFIED,
          QUANTITY,
          MIME_TYPE,
          FILENAME,
          PROVIDED,
          IN_DOCUMENT_ID,
          FS_ID,
          CREATED_AT
        ].freeze

        # Запрос Sequel на извлечение информации о документах
        DOCUMENTS_DATASET =
          Models::Document
          .join_table(:left, :scans, id: :scan_id)
          .select(*COLUMNS)
          .naked

        # Возвращает запрос Sequel на извлечение информации о документах заявки
        # @return [Sequel::Dataset]
        #   результирующий запрос Sequel
        def documents_dataset
          DOCUMENTS_DATASET.where(case_id: record.id)
        end
      end
    end
  end
end
