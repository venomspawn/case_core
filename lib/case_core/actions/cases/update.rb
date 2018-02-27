# encoding: utf-8

require "#{$lib}/actions/base/action"
require "#{$lib}/actions/base/mixins/transactional"

module CaseCore
  module Actions
    module Cases
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Класс действий над записями заявок, предоставляющих метод `update`,
      # который обновляет информацию о заявках
      #
      class Update < Base::Action
        require_relative 'update/params_schema'

        include Base::Mixins::Transactional
        include ParamsSchema

        # Список с названиями полей, импортируемых в таблицу атрибутов заявок
        #
        IMPORT_FIELDS = %i(case_id name value)

        # Обновляет атрибуты заявок с указанными идентификаторами
        #
        # @note
        #   В случае возникновения ошибки отменяются обновления атрибутов всех
        #   заявок
        #
        # @raise [Sequel::ForeignKeyConstraintViolation]
        #   если запись заявки не найдена по предоставленному идентификатору
        #
        def update
          transaction do
            attributes.where(case_id: ids, name: names).delete
            attributes.import(IMPORT_FIELDS, import_values)
          end
        end

        private

        # Возвращает список идентификаторов на основе значения атрибута `id`
        # ассоциативного массива параметров
        #
        # @return [Array]
        #   результирующий список
        #
        def ids
          @ids ||= Array(params[:id])
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
          ids.each_with_object([]) do |id, memo|
            names.each { |name| memo << [id, name, params[name.to_sym]] }
          end
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
