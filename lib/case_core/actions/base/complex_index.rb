# frozen_string_literal: true

require "#{$lib}/search/query"

require_relative 'action'

module CaseCore
  module Actions
    module Base
      # Абстрактный базовый класс действия извлечения информации о записях
      # вместе с атрибутами. Поддерживает только модели с основной таблицей
      # записей и таблицей записей атрибутов.
      class ComplexIndex < Action
        # Возвращает список ассоциативных массивов с информацией о записях
        # вместе с атрибутами
        # @return [Array<Hash>]
        #   результирующий список
        def index
          if fields? && attr_fields.empty?
            main_records
          else
            main_records.map(&method(:whole))
          end
        end

        private

        # Возвращает модель записей основной таблицы
        # @return [Class]
        #   модель записей основной таблицы
        def main_model
          raise "Метод `#{__method__}` не реализован"
        end

        # Возвращает модель записей таблицы атрибутов
        # @return [Class]
        #   модель записей таблицы атрибутов
        def attr_model
          raise "Метод `#{__method__}` не реализован"
        end

        # Возвращает запрос Sequel на извлечение записей основной таблицы,
        # отвечающей параметрам
        # @return [Sequel::Dataset]
        #   результирующий запрос Sequel
        def dataset
          @dataset ||=
            Search::Query.dataset(main_model, attr_model, query_params)
        end

        # Возвращает ассоциативный массив параметров создания запроса Sequel на
        # получение записей основной таблицы
        # @return [Hash]
        #   результирующий ассоциативный массив параметров
        def query_params
          params
        end

        # Возвращает список названий извлекаемых полей записей основной таблицы
        # и атрибутов, созданный на основе значения параметра `fields`, или
        # `nil`, если параметр `fields` не предоставлен
        # @return [Array<Symbol>]
        #   список названий извлекаемых полей и атрибутов
        # @return [NilClass]
        #   если параметр `fields` не предоставлен
        def fields
          @fields ||= Array(params[:fields]).map(&:to_sym) if fields?
        end

        # Возвращает, предоставлен ли параметр `fields`
        # @return [Boolean]
        #   предоставлен ли параметр `fields`
        def fields?
          params.key?(:fields)
        end

        # Возвращает список названий извлекаемых полей записей основной таблицы
        # или `nil`, если параметр `fields` не предоставлен
        # @return [Array<Symbol>]
        #   список названий извлекаемых полей
        # @return [NilClass]
        #   если параметр `fields` не предоставлен
        def main_fields
          @main_fields ||= extract_main_fields
        end

        # Формат строки с датой и временем
        DATETIME_FORMAT = 'YYYY-MM-DD"T"HH24:MI:SS'

        # Замена значений поля `created_at` на строки специального формата
        CREATED_AT = Sequel
                     .function(:to_char, :created_at, DATETIME_FORMAT)
                     .as(:created_at)

        # Возвращает список названий извлекаемых полей записей основной таблицы
        # @return [Array<Symbol>]
        #   список названий извлекаемых полей
        # @return [NilClass]
        #   если параметр `fields` не предоставлен
        def extract_main_fields
          result = main_model.columns.dup
          result &= fields if fields?
          result.push(:id).uniq!
          return result unless result.include?(:created_at)
          result.delete(:created_at) # nodoc
          result << CREATED_AT
        end

        # Возвращает список названий извлекаемых атрибутов или `nil`, если
        # параметр `fields` не предоставлен
        # @return [Array<Symbol>]
        #   список названий извлекаемых атрибутов
        # @return [NilClass]
        #   если параметр `fields` не предоставлен
        def attr_fields
          @attr_fields ||= fields - main_model.columns if fields?
        end

        # Возвращает список ассоциативных массивов с информацией о записях
        # основной таблицы
        # @return [Array<Hash>]
        #   результирующий список
        def main_records
          @main_records ||= dataset.select(*main_fields).naked.to_a
        end

        # Максимальное количество записей для использования списка
        # идентификаторов записей основной таблицы вместо вложенного запроса на
        # получение этих идентификаторов при создании запроса на получение
        # записей атрибутов.  Если выставить слишком большим, то запрос станет
        # слишком большим и его разбор затянется. Если выставить слишком
        # маленьким, то извлечение записей атрибутов будет слишком долгим из-за
        # обработки вложенного запроса.
        MAIN_RECORDS_THRESHOLD_COUNT = 200

        # Возвращает либо список идентификаторов записей основной таблицы, либо
        # запрос Sequel на извлечение этих идентификаторов в зависимости от
        # того, сколько записей основной таблицы извлекается методом
        # `main_records`
        # @return [Array]
        #   если записей основной таблицы извлечено не очень много
        # @return [Sequel::Dataset]
        #   если записей основной таблицы извлечено много
        def main_record_ids
          if main_records.count < MAIN_RECORDS_THRESHOLD_COUNT
            main_records.map { |hash| hash[:id] }
          else
            dataset.select(:id)
          end
        end

        # Возвращает название внешнего ключа таблицы атрибутов
        # @return [Symbol]
        #   название внешнего ключа таблицы атрибутов
        def attr_foreign_key
          @attr_foreign_key ||=
            attr_model
            .association_reflections
            .each_value
            .find { |refl| refl.associated_class == main_model }
            .default_key
        end

        # Возвращает запрос на получение названий и значений атрибутов
        # @return [Sequel::Dataset]
        #   результирующий запрос
        def attrs_dataset
          filtered = attr_model.where(attr_foreign_key => main_record_ids)
          return filtered unless attr_fields.present?
          attr_names = attr_fields.map(&:to_s)
          filtered.where(name: attr_names)
        end

        # Возвращает ассоциативный массив, в котором идентификаторам записей
        # основной таблицы соответствуют списки двухэлементных списков,
        # состоящих из названий и значений атрибутов
        # @return [Hash{Object => Array<(String, Object)>}]
        #   результирующий ассоциативный массив
        def attrs
          @attrs ||=
            attrs_dataset.select_hash_groups(attr_foreign_key, %i[name value])
        end

        # Возвращает ассоциативный массив со значениями полей записи основной
        # таблицы и атрибутов
        # @param [Hash] hash
        #   ассоциативный массив значений полей записи основной таблицы
        # @return [Hash]
        #   результирующий ассоциативный массив
        def whole(hash)
          id = hash[:id]
          attrs_array = attrs[id] || []
          attrs_hash = Hash[attrs_array].symbolize_keys
          hash.merge(attrs_hash)
        end
      end
    end
  end
end
