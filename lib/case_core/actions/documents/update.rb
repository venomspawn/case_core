# frozen_string_literal: true

require 'securerandom'

module CaseCore
  need 'actions/base/action'
  need 'actions/base/mixins/transactional'

  module Actions
    module Documents
      # Класс действий над записями документов, предоставляющих метод `update`,
      # который обновляет запись документа
      class Update < Base::Action
        require_relative 'update/params_schema'

        include Base::Mixins::Transactional

        # Обновляет запись документа
        def update
          transaction { scan.update(attrs) }
        end

        private

        # Список названий параметров, значения которых извлекается для
        # обновления полей записи
        PARAMS = %i[
          direction
          correct
          provided_as
          size
          last_modified
          quantity
          mime_type
          filename
          in_document_id
          fs_id
          created_at
        ]

        # Создаёт ассоциативный массив атрибутов записи документа на основе
        # параметров действия и возвращает его
        # @return [Hash]
        #   результирующий ассоциативный массив атрибутов записи документа
        def attrs
          params.slice(*PARAMS)
        end

        # Возвращает значение атрибута `:id` параметров действия
        # @return [Object]
        #   значение атрибута `:id` параметров действия
        def id
          params[:id]
        end

        # Возвращает значение атрибута `:case_id` параметров действия
        # @return [Object]
        #   значение атрибута `:case_id` параметров действия
        def case_id
          params[:case_id]
        end

        # Возвращает запрос Sequel на извлечение идентификатора записи
        # электронной копии документа
        # @return [Sequel::Dataset]
        #   результирующий запрос Sequel
        def id_dataset
          Models::Document.select(:scan_id).where(id: id, case_id: case_id)
        end

        # Возвращает запись электронной копии документа
        # @return [CaseCore::Models::Scan]
        #   запись электронной копии документа
        # @raise [Sequel::NoMatchingRow]
        #   если не найдена запись заявки или запись документа
        def scan
          Models::Scan.select(:id).where(id: id_dataset).first!
        end
      end
    end
  end
end
