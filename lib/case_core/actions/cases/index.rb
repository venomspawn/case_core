# frozen_string_literal: true

module CaseCore
  need 'actions/base/complex_index'

  module Actions
    module Cases
      # Класс действий над записями заявок, предоставляющий метод `index`,
      # который возвращает список ассоциативных массивов атрибутов заявок
      class Index < Base::ComplexIndex
        require_relative 'index/params_schema'

        private

        # Возвращает модель записей основной таблицы
        # @return [Class]
        #   модель записей основной таблицы
        def main_model
          Models::Case
        end

        # Возвращает модель записей таблицы атрибутов
        # @return [Class]
        #   модель записей таблицы атрибутов
        def attr_model
          Models::CaseAttribute
        end
      end
    end
  end
end
