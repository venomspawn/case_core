# encoding: utf-8

require "#{$lib}/actions/base/action"

# Предварительное создание класса, чтобы не надо было указывать в дальнейшем
# базовый класс
CaseCore::Actions::Cases::Update = Class.new(CaseCore::Actions::Base::Action)

require_relative 'update/params_schema'

module CaseCore
  module Actions
    module Cases
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Класс действий над записями заявок, предоставляющих метод `update`,
      # который обновляет информацию о заявке
      #
      class Update
        include ParamsSchema

        # Список с названиями полей, импортируемых в таблицу атрибутов заявок
        #
        IMPORT_FIELDS = %i(case_id name value)

        # Обновляет запись заявки с указанным идентификатором
        #
        # @return [Hash]
        #   результирующий ассоциативный массив
        #
        # @raise [Sequel::ForeignKeyConstraintViolation]
        #   если запись заявки не найдена по предоставленному идентификатору
        #
        def update
          Sequel::Model.db.transaction(savepoint: :only) do
            attributes.where(case_id: id, name: names).delete
            attributes.import(IMPORT_FIELDS, import_values)
          end
        end

        private

        # Возвращает значение атрибута `id` ассоциативного массива параметров
        #
        # @return [Object]
        #   результирующее значение
        #
        def id
          @id ||= params[:id].to_s
        end

        # Возвращает список названий обновляемых атрибутов
        #
        # @return [Array<Symbol>]
        #   список названий обновляемых атрибутов
        #
        def names
          @names ||= (params.keys - %i(id)).map(&:to_s)
        end

        # Возвращает список трёхэлементных списков значений полей записей
        # таблицы атрибутов заявок
        #
        # @return [Array<Array<(String, String, Object)>>]
        #   результирующий список
        #
        def import_values
          names.map { |name| [id, name, params[name.to_sym]] }
        end

        # Возвращает запрос Sequel на получение всех записей атрибутов заявки
        #
        # @return [Sequel::Dataset]
        #   результирующий запрос Sequel
        #
        def attributes
          Models::CaseAttribute.dataset.naked
        end
      end
    end
  end
end
