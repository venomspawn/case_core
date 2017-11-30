# encoding: utf-8

require "#{$lib}/actions/base/action"

# Предварительное создание класса, чтобы не надо было указывать в дальнейшем
# базовый класс
CaseCore::Actions::Registers::Index =
  Class.new(CaseCore::Actions::Base::Action)

require_relative 'index/params_schema'
require_relative 'index/result_schema'

module CaseCore
  module Actions
    module Registers
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Класс действий над реестрами передаваемой корреспонденции,
      # предоставляющий метод `index`, который возвращает список ассоциативных
      # массивов атрибутов реестров передаваемой корреспонденции
      #
      class Index
        include ParamsSchema
        include ResultSchema

        # Возвращает список ассоциативных массивов атрибутов реестров
        # передаваемой корреспонденции
        #
        # @return [Array<Hash>]
        #   список ассоциативных массивов атрибутов реестров передаваемой
        #   корреспонденции
        #
        def index
          registers_dataset.naked.all do |register_info|
            id = register_info[:id]
            register_info[:items_count] = register_items_count[id] || 0
          end
        end

        private

        # Возвращает значение атрибута `filter` ассоциативного массива
        # параметров или пустой ассоциативный массив, если атрибут отсутствует
        #
        # @return [Hash]
        #   результирующее значение
        #
        def filter
          params[:filter] || {}
        end

        # Возвращает запрос Sequel на получение всех записей реестров
        # передаваемой корреспонденции, удовлетворяющих условиям, заданных с
        # помощью метода {filter}
        #
        # @return [Sequel::Dataset]
        #   запрос Sequel на получение записей реестров передаваемой
        #   корреспонденции
        #
        def registers_dataset
          Models::Register.where(filter)
        end

        # Возвращает запрос Sequel на получение всех идентификаторов записей
        # реестров передаваемой корреспонденции, удовлетворяющих условиям,
        # заданных с помощью метода {filter}
        #
        # @return [Sequel::Dataset]
        #   запрос Sequel на получение идентификаторов записей реестров
        #   передаваемой корреспонденции
        #
        def register_ids_dataset
          registers_dataset.select(:id)
        end

        # Возвращает запрос Sequel на получение информации по количествам
        # заявок в реестрах передаваемой корреспонденции
        #
        # @return [Sequel::Dataset]
        #   запрос Sequel на получение информации по количествам заявок в
        #   реестрах передаваемой корреспонденции
        #
        def counts_dataset
          CaseCore::Models::CaseRegister
            .where(register_id: register_ids_dataset)
            .group_and_count(:register_id)
            .naked
        end

        # Возвращает ассоциативный массив, в котором идентификаторам записей
        # реестров передаваемой корреспонденции сопоставлены количества заявок
        # в этих реестрах
        #
        # @return [Hash{Integer => Integer}]
        #   результирующий ассоциативный массив
        #
        def register_items_count
          @registers_count ||=
            counts_dataset.each_with_object({}) do |count_info, memo|
              register_id = count_info[:register_id]
              count = count_info[:count]
              memo[register_id] = count
            end
        end
      end
    end
  end
end
