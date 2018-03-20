# frozen_string_literal: true

require "#{$lib}/actions/base/action"

module CaseCore
  module Actions
    module Cases
      # Класс действий над записями заявок, предоставляющих метод `show`,
      # который возвращает информацию о заявке
      class Show < Base::Action
        require_relative 'show/params_schema'
        require_relative 'show/result_schema'

        # Возвращает ассоциативный массив со всеми атрибутами заявки
        # @return [Hash]
        #   результирующий ассоциативный массив
        # @raise [Sequel::NoMatchingRow]
        #   если запись заявки не найдена
        def show
          return record.values if names.is_a?(Array) && names.empty?
          attributes_dataset
            .select_hash(:name, :value, hash: record.values)
            .symbolize_keys
        end

        private

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

        # Возвращает запись заявки
        # @return [CaseCore::Models::Case]
        #   запись заявки
        # @raise [Sequel::NoMatchingRow]
        #   если запись заявки не найдена
        def record
          @record ||= CaseCore::Models::Case.with_pk!(id)
        end

        # Возвращает запрос Sequel на получение записей атрибутов заявки
        # @return [Sequel::Dataset]
        #   результирующий запрос
        # @raise [Sequel::NoMatchingRow]
        #   если запись заявки не найдена
        def attributes_dataset
          dataset = record.attributes_dataset
          dataset = dataset.where(name: names) unless names.nil?
          dataset.select(:name, :value).naked
        end
      end
    end
  end
end
