# encoding: utf-8

require "#{$lib}/actions/base/action"

# Предварительное создание класса, чтобы не надо было указывать в дальнейшем
# базовый класс
CaseCore::Actions::Requests::Update =
  Class.new(CaseCore::Actions::Base::Action)

require_relative 'update/params_schema'

module CaseCore
  module Actions
    module Requests
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Класс действий над записями межведомственных запросов, предоставляющих
      # метод `update`, который обновляет атрибуты межведомственных запросов
      #
      class Update
        include ParamsSchema

        # Список с названиями полей, значения которых импортируются в таблицу
        # атрибутов межведомственных запросов
        #
        IMPORT_FIELDS = %i(request_id name value)

        # Обновляет атрибуты межведомственного запроса с указанным
        # идентификатором записи
        #
        # @raise [Sequel::ForeignKeyConstraintViolation]
        #   если запись межведомственного запроса не найдена по
        #   предоставленному идентификатору
        #
        def update
          Sequel::Model.db.transaction(savepoint: :only) do
            attributes.where(request_id: id, name: names).delete
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

        # Возвращает запрос Sequel на получение всех записей атрибутов
        # межведомственных запросов
        #
        # @return [Sequel::Dataset]
        #   результирующий запрос Sequel
        #
        def attributes
          Models::RequestAttribute.dataset.naked
        end
      end
    end
  end
end
