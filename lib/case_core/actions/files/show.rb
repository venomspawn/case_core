# frozen_string_literal: true

module CaseCore
  need 'actions/base/action'

  module Actions
    module Files
      # Класс действий, возвращающих содержимое файлов
      class Show < Base::Action
        require_relative 'show/params_schema'

        # Возвращает содержимое файла
        # @return [String]
        #   содержимое файла
        def show
          record.content
        end

        private

        # Возвращает значение атрибута `id` ассоциативного массива параметров
        # @return [Object]
        #   результирующее значение
        def id
          params[:id]
        end

        # Возвращает запись файла
        # @return [CaseCore::Models::File]
        #   запись файла
        # @raise [Sequel::NoMatchingRow]
        #   если запись файла невозможно найти
        def record
          Models::File.select(:content).with_pk!(id)
        end
      end
    end
  end
end
