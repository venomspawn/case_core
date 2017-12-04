# encoding: utf-8

require 'securerandom'

require "#{$lib}/actions/base/action"

# Предварительное создание класса, чтобы не надо было указывать в дальнейшем
# базовый класс
CaseCore::Actions::Documents::Create =
  Class.new(CaseCore::Actions::Base::Action)

require_relative 'create/params_schema'

module CaseCore
  module Actions
    module Documents
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Класс действий над записями документов, предоставляющих метод `create`,
      # который создаёт запись документа и прикрепляет её к записи заявки
      #
      class Create
        include ParamsSchema

        # Создаёт запись документа и прикрепляет её к записи заявки
        #
        def create
          Sequel::Model.db.transaction(savepoint: :only) do
            Models::Document.create(attrs)
          end
        end

        private

        # Создаёт ассоциативный массив атрибутов записи документа на основе
        # параметров действия и возвращает его
        #
        # @return [Hash]
        #   результирующий ассоциативный массив атрибутов записи документа
        #
        def attrs
          params.dup.tap { |result| result[:id] ||= SecureRandom.uuid }
        end
      end
    end
  end
end
