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
          record.documents_dataset.naked.to_a
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
      end
    end
  end
end
