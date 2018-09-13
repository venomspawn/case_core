# frozen_string_literal: true

require 'securerandom'

module CaseCore
  need 'actions/base/action'
  need 'actions/base/mixins/transactional'

  module Actions
    module Documents
      # Класс действий над записями документов, предоставляющих метод `create`,
      # который создаёт запись документа и прикрепляет её к записи заявки
      class Create < Base::Action
        require_relative 'create/params_schema'

        include Base::Mixins::Transactional

        # Создаёт запись документа и прикрепляет её к записи заявки
        def create
          transaction { Models::Document.create(attrs) }
        end

        private

        # Список названий атрибутов, извлекаемых из параметров действия при
        # создании записи документа
        DOCUMENT_ATTRS = %i[id case_id title].freeze

        # Создаёт ассоциативный массив атрибутов записи документа на основе
        # параметров действия и возвращает его
        # @return [Hash]
        #   результирующий ассоциативный массив атрибутов записи документа
        def attrs
          params.slice(*DOCUMENT_ATTRS).tap do |result|
            result[:id] ||= SecureRandom.uuid
            result[:scan_id] = create_scan
          end
        end

        # Возвращает значение параметра `provided` или `nil`, если значение
        # параметра не предоставлено
        # @return [Object]
        #   результирующее значение
        def provided
          params[:provided]
        end

        # Возвращает, предоставлено ли значение параметра `provided` и равно ли
        # оно булевому `true`
        # @return [Boolean]
        #   предоставлено ли значение параметра `provided` и равно ли оно
        #   булевому `true`
        def provided?
          provided.is_a?(TrueClass)
        end

        # Возвращает значение параметра `fs_id` или `nil`, если значение
        # параметра не предоставлено
        # @return [Object]
        #   результирующее значение
        def fs_id
          params[:fs_id]
        end

        # Список названий атрибутов, извлекаемых из параметров действия при
        # создании записи электронной копии документа
        SCAN_ATTRS = %i[
          direction
          correct
          provided_as
          size
          last_modified
          quantity
          mime_type
          filename
          in_document_id
          created_at
          fs_id
        ].freeze

        # Создаёт запись электронной копии документа и возвращает её
        # идентификатор в случае, если значение параметра `provided` равно
        # булевому `true` и значение параметра `fs_id` присутствует и не равно
        # `nil`. Возвращает `nil` в противном случае.
        # @return [Integer]
        #   идентификатор созданной записи
        # @return [NilClass]
        #   если параметр `provided` не равен булеву значению `true` или если
        #   значение `fs_id` отсутствует или равно `nil`
        def create_scan
          return if !provided? || fs_id.nil?
          fields = params.slice(*SCAN_ATTRS)
          Models::Scan.create(fields).id
        end
      end
    end
  end
end
