# encoding: utf-8

require "#{$lib}/actions/base/action"

# Предварительное создание класса, чтобы не надо было указывать в дальнейшем
# базовый класс
CaseCore::Actions::Documents::Index =
  Class.new(CaseCore::Actions::Base::Action)

require_relative 'index/params_schema'
require_relative 'index/result_schema'

module CaseCore
  module Actions
    module Documents
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Класс действий над записями документов, предоставляющий метод `index`,
      # который возвращает список ассоциативных массивов атрибутов документов,
      # прикреплённых к заявке
      #
      class Index
        include ParamsSchema
        include ResultSchema

        # Возвращает список ассоциативных массивов атрибутов документов,
        # прикреплённых к заявке
        #
        # @return [Array<Hash>]
        #   список ассоциативных массивов атрибутов документов, прикреплённых к
        #   заявке
        #
        def index
          record.documents_dataset.naked.to_a
        end

        private

        # Возвращает запись заявки
        #
        # @return [CaseCore::Models::Case]
        #   запись заявки
        #
        # @raise [Sequel::NoMatchingRow]
        #   если запись заявки не найдена
        #
        def record
          @record ||= CaseCore::Models::Case.with_pk!(id)
        end

        # Возвращает значение атрибута `id` ассоциативного массива параметров
        #
        # @return [Object]
        #   результирующее значение
        #
        def id
          params[:id]
        end
      end
    end
  end
end
