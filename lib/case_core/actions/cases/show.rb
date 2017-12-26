# encoding: utf-8

require "#{$lib}/actions/base/action"

# Предварительное создание класса, чтобы не надо было указывать в дальнейшем
# базовый класс
CaseCore::Actions::Cases::Show = Class.new(CaseCore::Actions::Base::Action)

require_relative 'show/params_schema'
require_relative 'show/result_schema'

module CaseCore
  module Actions
    module Cases
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Класс действий над записями заявок, предоставляющих метод `show`,
      # который возвращает информацию о заявке
      #
      class Show
        include ParamsSchema
        include ResultSchema

        # Возвращает ассоциативный массив со всеми атрибутами заявки
        #
        # @return [Hash]
        #   результирующий ассоциативный массив
        #
        # @raise [Sequel::NoMatchingRow]
        #   если запись заявки не найдена
        #
        def show
          attributes_dataset = record.attributes_dataset.naked
          attributes_dataset
            .select_hash(:name, :value, hash: record.values)
            .symbolize_keys
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
