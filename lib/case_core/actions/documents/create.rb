# frozen_string_literal: true

require 'securerandom'

require "#{$lib}/actions/base/action"
require "#{$lib}/actions/base/mixins/transactional"

module CaseCore
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

        # Создаёт ассоциативный массив атрибутов записи документа на основе
        # параметров действия и возвращает его
        # @return [Hash]
        #   результирующий ассоциативный массив атрибутов записи документа
        def attrs
          params.dup.tap { |result| result[:id] ||= SecureRandom.uuid }
        end
      end
    end
  end
end
