# encoding: utf-8

require 'securerandom'

require "#{$lib}/actions/base/action"

# Предварительное создание класса, чтобы не надо было указывать в дальнейшем
# базовый класс
CaseCore::Actions::Documents::Update =
  Class.new(CaseCore::Actions::Base::Action)

require_relative 'update/params_schema'

module CaseCore
  module Actions
    module Documents
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Класс действий над записями документов, предоставляющих метод `update`,
      # который обновляет запись документа
      #
      class Update
        include ParamsSchema

        # Обновляет запись документа
        #
        def update
          Sequel::Model.db.transaction(savepoint: :only) do
            record.update(attrs)
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
