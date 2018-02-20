# encoding: utf-8

require "#{$lib}/search/query"

require_relative 'action'

module CaseCore
  module Actions
    module Base
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Абстрактный базовый класс действия извлечения информации о записях
      # вместе с атрибутами. Поддерживает только модели с основной таблицей
      # записей и таблицей записей атрибутов.
      #
      class ComplexIndex < Action
        # Возвращает список ассоциативных массивов с информацией о записях
        # вместе с атрибутами
        #
        # @return [Array<Hash>]
        #   результирующий список
        #
        def index
          if fields? && attr_fields.empty?
            main_records
          else
            main_records.map(&method(:whole))
          end
        end

        private

        # Возвращает модель записей основной таблицы
        #
        # @return [Class]
        #   модель записей основной таблицы
        #
        def main_model
          raise 'Вызов абстрактного метода'
        end

        # Возвращает модель записей таблицы атрибутов
        #
        # @return [Class]
        #   модель записей таблицы атрибутов
        #
        def attr_model
          raise 'Вызов абстрактного метода'
        end

        # Возвращает запрос Sequel на извлечение записей основной таблицы,
        # отвечающей параметрам
        #
        # @return [Sequel::Dataset]
        #   результирующий запрос Sequel
        #
        def dataset
          @dataset ||= Search::Query.dataset(main_model, attr_model, params)
        end

        # Возвращает список названий извлекаемых полей записей основной таблицы
        # и атрибутов, являющийся значением параметра `fields`, или `nil`, если
        # параметр `fields` не предоставлен
        #
        # @return [Array<Symbol>]
        #   список названий извлекаемых полей и атрибутов
        #
        # @return [NilClass]
        #   если параметр `fields` не предоставлен
        #
        def fields
          @fields ||= params[:fields]&.map(&:to_sym)
        end

        # Возвращает, предоставлен ли параметр `fields`
        #
        # @return [Boolean]
        #   предоставлен ли параметр `fields`
        #
        def fields?
          params.key?(:fields)
        end

        # Возвращает список названий извлекаемых полей записей основной таблицы
        # или `nil`, если параметр `fields` не предоставлен
        #
        # @return [Array<Symbol>]
        #   список названий извлекаемых полей
        #
        # @return [NilClass]
        #   если параметр `fields` не предоставлен
        #
        def main_fields
          @main_fields ||= fields & main_model.columns if fields?
        end

        # Возвращает список названий извлекаемых атрибутов или `nil`, если
        # параметр `fields` не предоставлен
        #
        # @return [Array<Symbol>]
        #   список названий извлекаемых атрибутов
        #
        # @return [NilClass]
        #   если параметр `fields` не предоставлен
        #
        def attr_fields
          @attr_fields ||= fields - main_model.columns if fields?
        end

        # Возвращает список ассоциативных массивов с информацией о записях
        # основной таблицы
        #
        # @return [Array<Hash>]
        #   результирующий список
        #
        def main_records
          return @main_records unless @main_records.nil?
          return @main_records = dataset.naked.to_a unless fields?
          target_fields = main_fields.empty? ? %i(id) : main_fields
          @main_records = dataset.select(*target_fields).naked.to_a
        end

        # Возвращает название внешнего ключа таблицы атрибутов
        #
        # @return [Symbol]
        #   название внешнего ключа таблицы атрибутов
        #
        def attr_foreign_key
          @attr_foreign_key ||=
            attr_model
            .association_reflections
            .each_value
            .find { |refl| refl.associated_class == main_model }
            .default_key
        end

        # Возвращает запрос на получение названий и значений атрибутов
        #
        # @return [Sequel::Dataset]
        #   результирующий запрос
        #
        def attrs_dataset
          dataset = attr_model.where(attr_foreign_key => dataset.select(:id))
          return dataset unless attr_fields.present?
          attr_names = attr_fields.map(&:to_s)
          dataset.where(name: attr_names)
        end

        # Возвращает ассоциативный массив, в котором идентификаторам записей
        # основной таблицы соответствуют списки двухэлементных списков,
        # состоящих из названий и значений атрибутов
        #
        # @return [Hash{Object => Array<(String, Object)>}]
        #   результирующий ассоциативный массив
        #
        def attrs
          @attr_records ||=
            attrs_dataset.select_hash_groups(attr_foreign_key, %i(name value))
        end

        # Возвращает ассоциативный массив со значениями полей записи основной
        # таблицы и атрибутов
        #
        # @param [Hash] hash
        #   ассоциативный массив значений полей записи основной таблицы
        #
        # @return [Hash]
        #   результирующий ассоциативный массив
        #
        def whole(hash)
          id = hash[:id]
          attrs_array = attrs[id] || []
          attrs_hash = Hash[attrs_array].symbolize
          hash.merge(attrs_hash)
        end
      end
    end
  end
end
