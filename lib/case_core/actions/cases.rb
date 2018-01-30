# encoding: utf-8

module CaseCore
  module Actions
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Пространство имён для действий над записями заявок
    #
    module Cases
      require_relative 'cases/call'

      # Вызывает метод модуля бизнес-логики с записью заявки в качестве
      # аргумента
      #
      # @param [Hash] params
      #   ассоциативный массив параметров действия
      #
      # @raise [Sequel::NoMatchingRow]
      #   если запись заявки не найдена по предоставленному идентификатору
      #
      # @raise [RuntimeError]
      #   если модуль бизнес-логики не найден по типу заявки
      #
      def self.call(params)
        Call.new(params).call
      end

      require_relative 'cases/create'

      # Создаёт новую запись заявки вместе с записями приложенных документов
      #
      # @raise [RuntimeError]
      #   если не найдена бизнес-логика, обрабатывающая создание заявки
      #
      # @raise [RuntimeError]
      #   если модуль бизнес-логики не предоставляет функцию `on_case_creation`
      #   для вызова с созданной заявкой в качестве аргумента
      #
      # @raise [ArgumentError]
      #   если во время вызова функции `on_case_creation` модуля бизнес-логики
      #   создалось исключение класса `ArgumentError`
      #
      def self.create(params)
        Create.new(params).create
      end

      require_relative 'cases/index'

      # Возвращает список ассоциативных массивов атрибутов заявок
      #
      # @param [Hash] params
      #   ассоциативный массив параметров действия
      #
      # @return [Array<Hash>]
      #   список ассоциативных массивов атрибутов заявок
      #
      def self.index(params)
        Index.new(params).index
      end

      require_relative 'cases/show'

      # Возвращает ассоциативный массив с информацией о заявке с
      # предоставленным идентификатором записи
      #
      # @param [Hash] params
      #   ассоциативный массив параметров действия
      #
      # @return [Hash]
      #   результирующий ассоциативный массив
      #
      def self.show(params)
        Show.new(params).show
      end

      require_relative 'cases/show_attributes'

      # Возвращает ассоциативный массив с информацией об атрибутах заявки,
      # кроме тех, что присутствуют непосредственно в записи заявки
      #
      # @param [Hash] params
      #   ассоциативный массив параметров действия
      #
      # @return [Hash]
      #   результирующий ассоциативный массив
      #
      def self.show_attributes(params)
        ShowAttributes.new(params).show_attributes
      end

      require_relative 'cases/update'

      # Обновляет запись заявки с указанным идентификатором
      #
      # @param [Hash] params
      #   ассоциативный массив параметров действия
      #
      # @raise [Sequel::ForeignKeyConstraintViolation]
      #   если запись заявки не найдена по предоставленному идентификатору
      #
      # @raise [JSON::Schema::ValidationError]
      #   если в ассоциативном массиве параметров действия присутствует поле
      #   `type` или поле `created_at`
      #
      def self.update(params)
        Update.new(params).update
      end
    end
  end
end
