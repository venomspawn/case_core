# frozen_string_literal: true

require 'securerandom'

require "#{$lib}/actions/base/action"
require "#{$lib}/actions/base/mixins/transactional"

module CaseCore
  module Actions
    module Documents
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Класс действий над записями документов, предоставляющих метод `update`,
      # который обновляет запись документа
      #
      class Update < Base::Action
        require_relative 'update/params_schema'

        include Base::Mixins::Transactional

        # Обновляет запись документа
        #
        def update
          transaction { record.update(attrs) }
        end

        private

        # Создаёт ассоциативный массив атрибутов записи документа на основе
        # параметров действия и возвращает его
        #
        # @return [Hash]
        #   результирующий ассоциативный массив атрибутов записи документа
        #
        def attrs
          params.except(:id, :case_id)
        end

        # Возвращает значение атрибута `:id` параметров действия
        #
        # @return [Object]
        #   значение атрибута `:id` параметров действия
        #
        def id
          params[:id]
        end

        # Возвращает значение атрибута `:case_id` параметров действия
        #
        # @return [Object]
        #   значение атрибута `:case_id` параметров действия
        #
        def case_id
          params[:case_id]
        end

        # Возвращает запись документа
        #
        # @return [CaseCore::Models::Document]
        #   запись документа
        #
        # @raise [Sequel::NoMatchingRow]
        #   если не найдена запись заявки или запись документа
        #
        def record
          Models::Document.where(id: id, case_id: case_id).first!
        end
      end
    end
  end
end
