# frozen_string_literal: true

require "#{$lib}/actions/base/action"

module CaseCore
  module Actions
    module Cases
      # Класс действий над записями заявок, предоставляющих метод
      # `show_attributes`, который возвращает информацию об атрибутах заявки,
      # кроме тех, что присутствуют непосредственно в записи заявки
      class ShowAttributes < Base::Action
        require_relative 'show_attributes/params_schema'
        require_relative 'show_attributes/result_schema'

        # Возвращает ассоциативный массив со всеми атрибутами заявки, кроме
        # тех, что присутствуют непосредственно в записи заявки
        # @return [Hash{Symbol => Object}]
        #   результирующий ассоциативный массив
        # @raise [Sequel::NoMatchingRow]
        #   если запись заявки не найдена
        def show_attributes
          return {} if names.is_a?(Array) && names.empty?
          attributes_dataset.select_hash(:name, :value).symbolize_keys
        end

        private

        # Возвращает запрос Sequel на получение записей атрибутов заявки
        # @return [Sequel::Dataset]
        #   результирующий запрос
        def attributes_dataset
          dataset = Models::CaseAttribute.where(case_id: id)
          dataset = dataset.where(name: names) unless names.nil?
          dataset.select(:name, :value).naked
        end

        # Возвращает значение атрибута `id` ассоциативного массива параметров
        # @return [Object]
        #   результирующее значение
        def id
          params[:id]
        end

        # Возвращает значение атрибута `names` ассоциативного массива
        # параметров
        # @return [NilClass, Array]
        #   значение атрибута `names`
        def names
          @names ||= params[:names]&.map(&:to_s)
        end
      end
    end
  end
end
