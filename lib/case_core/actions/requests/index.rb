# encoding: utf-8

require "#{$lib}/actions/base/action"

# Предварительное создание класса, чтобы не надо было указывать в дальнейшем
# базовый класс
CaseCore::Actions::Requests::Index = Class.new(CaseCore::Actions::Base::Action)

require_relative 'index/params_schema'
require_relative 'index/result_schema'

module CaseCore
  module Actions
    module Requests
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Класс действий над записями межведомственных запросов, предоставляющий
      # метод `index`, который возвращает список ассоциативных массивов
      # атрибутов межведомственных запросов, созданных в рамках заявки
      #
      class Index
        include ParamsSchema
        include ResultSchema

        # Возвращает список ассоциативных массивов атрибутов межведомственных
        # запросов, созданных в рамках заявки
        #
        # @return [Array<Hash>]
        #   список ассоциативных массивов атрибутов межведомственных запросов,
        #   созданных в рамках заявки
        #
        def index
          attrs_info.map do |(request_id, attrs)|
            Hash[attrs].merge(request_hash(request_id))
          end
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

        # Поля, извлекаемые из записей межведомственных запросов
        #
        REQUEST_FIELDS = %i[id created_at]

        # Возвращает ассоциативный массив, в котором идентификаторы записей
        # межведомственных запросов, созданных в рамках заявки, отображаются в
        # списки значений их полей, чьи имена заданы константой
        # {REQUEST_FIELDS}
        #
        # @return [Hash]
        #   результирующий ассоциативный массив
        #
        def requests
          @requests ||=
            record.requests_dataset.select_hash(:id, REQUEST_FIELDS)
        end

        # Возвращает ассоциативный массив атрибутов межведомственного запроса с
        # предоставленным идентификатором записи
        #
        # @param [Integer] request_id
        #   идентификатор записи межведомственного запроса
        #
        def request_hash(request_id)
          request_values = requests[request_id]
          Hash[REQUEST_FIELDS.zip(request_values)]
        end

        # Возвращает список идентификаторов записей межведомственных запросов,
        # созданных в рамках заявки
        #
        # @return [Array]
        #   результирующий список
        #
        def request_ids
          requests.keys
        end

        # Возвращает запрос Sequel на извлечение записей атрибутов
        # межведомственных запросов, созданных в рамках заявки
        #
        # @return [Sequel::Dataset]
        #   результирующий запрос
        #
        def attrs_dataset
          Models::RequestAttribute.dataset.where(request_id: request_ids)
        end

        # Возвращает ассоциативный массив, в котором идентификаторы
        # межведомственных запросов, созданных в рамках заявки, отображаются в
        # списки двухэлементных списков из названий и значений атрибутов этих
        # запросов
        #
        # @return [Hash]
        #   результирующий ассоциативный массив
        #
        def attrs_info
          attrs_dataset.select_hash_groups(:request_id, %i[name value])
        end
      end
    end
  end
end
