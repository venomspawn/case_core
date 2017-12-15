# encoding: utf-8

require "#{$lib}/actions/base/action"

# Предварительное создание класса, чтобы не надо было указывать в дальнейшем
# базовый класс
CaseCore::Actions::Registers::Show = Class.new(CaseCore::Actions::Base::Action)

require_relative 'show/params_schema'
require_relative 'show/result_schema'

module CaseCore
  module Actions
    module Registers
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Класс действий над реестрами передаваемой корреспонденции,
      # предоставляющий метод `show`, который возвращает информацию о реестре
      # передаваемой корреспонденции с данным идентификатором записи
      #
      class Show
        include ParamsSchema
        include ResultSchema

        # Возвращает ассоциативный массив с информацией о реестре передаваемой
        # корреспонденции с данным идентификатором записи
        #
        # @return [Hash]
        #   ассоциативный массив с информацией о реестре передаваемой
        #   корреспонденции с данным идентификатором записи
        #
        def show
          record.values.tap do |result|
            result[:items_count] = cases_info.size
            result[:items] = items
          end
        end

        private

        # Возвращает запись заявки
        #
        # @return [CaseCore::Models::Register]
        #   запись заявки
        #
        # @raise [Sequel::NoMatchingRow]
        #   если запись заявки не найдена
        #
        def record
          @record ||= CaseCore::Models::Register.with_pk!(id)
        end

        # Возвращает значение атрибута `id` ассоциативного массива параметров
        #
        # @return [Object]
        #   результирующее значение
        #
        def id
          params[:id]
        end

        # Поля записей заявок, подлежащие извлечению
        #
        CASE_FIELDS = %i(id created_at)

        # Возвращает ассоциативный массив, в котором идентификаторам записей
        # заявок соответствуют значения извлечённых полей этих записей
        #
        # @return [Hash{String => Array}]
        #   результирующий ассоциативный массив
        #
        def cases_info
          @cases_info ||=
            record.cases_dataset.select_hash(:id, CASE_FIELDS)
        end

        # Возвращает список идентификаторов заявок
        #
        # @return [Array<String>]
        #   список идентификаторов заявок
        #
        def case_ids
          cases_info.keys
        end

        # Возвращает запрос Sequel на получение всех записей атрибутов заявок с
        # данными идентификаторами
        #
        # @return [Sequel::Dataset]
        #   результирующий запрос Sequel
        #
        def case_attributes_dataset
          Models::CaseAttribute.where(case_id: case_ids)
        end

        # Возвращает ассоциативный массив, в котором идентификаторам записей
        # заявок соответствуют списки двухэлементных списков из названий и
        # значений атрибутов заявок
        #
        # @return [Hash{String => Array<Array<(String, Object)>>}]
        #   результирующий ассоциативный массив
        #
        def case_attributes_values
          @case_attributes_info ||=
            case_attributes_dataset
            .select_hash_groups(:case_id, %i(name value))
        end

        # Создаёт и возвращает ассоциативный массив атрибутов заявки
        #
        # @param [Array<Array<(String, Object)>>]
        #   список двухэлеметных списков из названий и значений атрибутов
        #   заявки
        #
        # @return [Hash]
        #   результирующий ассоциативный массив
        #
        def fill_attributes_info(values)
          Hash[values].tap do |result|
            result[:service_id]   ||= nil
            result[:applicant_id] ||= nil
            result[:state]        ||= nil
          end
        end

        # Возвращает список ассоциативных массивов с информацией о заявках,
        # находящихся в реестре передаваемой корреспонденции
        #
        # @return [Array<Hash>]
        #   результирующий список
        #
        def items
          cases_info.map do |(case_id, case_values)|
            values = case_attributes_values[case_id] || []
            attributes_info = fill_attributes_info(values)
            case_info = Hash[CASE_FIELDS.zip(case_values)]
            case_info.merge(attributes_info)
          end
        end
      end
    end
  end
end
