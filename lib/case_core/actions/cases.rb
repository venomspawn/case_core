# frozen_string_literal: true

module CaseCore
  module Actions
    # Пространство имён для действий над записями заявок
    module Cases
      require_relative 'cases/call'

      # Вызывает метод модуля бизнес-логики с записью заявки в качестве
      # аргумента
      # @param [Object] params
      #   параметры действия
      # @param [NilClass, Hash] rest
      #   ассоциативный массив дополнительных параметров действия или `nil`,
      #   если дополнительные параметры отсутствуют
      # @raise [Sequel::NoMatchingRow]
      #   если запись заявки не найдена по предоставленному идентификатору
      # @raise [RuntimeError]
      #   если модуль бизнес-логики не найден по типу заявки
      def self.call(params, rest = nil)
        Call.new(params, rest).call
      end

      require_relative 'cases/count'

      # Возвращает ассоциативный массив с количеством записей заявок
      # @param [Object] params
      #   параметры действия
      # @param [NilClass, Hash] rest
      #   ассоциативный массив дополнительных параметров действия или `nil`,
      #   если дополнительные параметры отсутствуют
      # @return [Hash]
      #   ассоциативный массив с единственным атрибутом `count`, содержащим
      #   количество записей заявок
      def self.count(params, rest = nil)
        Count.new(params, rest).count
      end

      require_relative 'cases/create'

      # Создаёт новую запись заявки вместе с записями приложенных документов и
      # возвращает созданную запись
      # @param [Object] params
      #   параметры действия
      # @return [CaseCore::Models::Case]
      #   созданная запись заявки
      # @param [NilClass, Hash] rest
      #   ассоциативный массив дополнительных параметров действия или `nil`,
      #   если дополнительные параметры отсутствуют
      # @raise [RuntimeError]
      #   если не найдена бизнес-логика, обрабатывающая создание заявки
      # @raise [RuntimeError]
      #   если модуль бизнес-логики не предоставляет функцию `on_case_creation`
      #   для вызова с созданной заявкой в качестве аргумента
      # @raise [ArgumentError]
      #   если во время вызова функции `on_case_creation` модуля бизнес-логики
      #   создалось исключение класса `ArgumentError`
      def self.create(params, rest = nil)
        Create.new(params, rest).create
      end

      require_relative 'cases/index'

      # Возвращает список ассоциативных массивов атрибутов заявок
      # @param [Object] params
      #   параметры действия
      # @param [NilClass, Hash] rest
      #   ассоциативный массив дополнительных параметров действия или `nil`,
      #   если дополнительные параметры отсутствуют
      # @return [Array<Hash>]
      #   список ассоциативных массивов атрибутов заявок
      def self.index(params, rest = nil)
        Index.new(params, rest).index
      end

      require_relative 'cases/show'

      # Возвращает ассоциативный массив с информацией о заявке с
      # предоставленным идентификатором записи
      # @param [Object] params
      #   параметры действия
      # @param [NilClass, Hash] rest
      #   ассоциативный массив дополнительных параметров действия или `nil`,
      #   если дополнительные параметры отсутствуют
      # @return [Hash]
      #   результирующий ассоциативный массив
      def self.show(params, rest = nil)
        Show.new(params, rest).show
      end

      require_relative 'cases/show_attributes'

      # Возвращает ассоциативный массив с информацией об атрибутах заявки,
      # кроме тех, что присутствуют непосредственно в записи заявки
      # @param [Object] params
      #   параметры действия
      # @param [NilClass, Hash] rest
      #   ассоциативный массив дополнительных параметров действия или `nil`,
      #   если дополнительные параметры отсутствуют
      # @return [Hash]
      #   результирующий ассоциативный массив
      def self.show_attributes(params, rest = nil)
        ShowAttributes.new(params, rest).show_attributes
      end

      require_relative 'cases/update'

      # Обновляет запись заявки с указанным идентификатором
      # @param [Object] params
      #   параметры действия
      # @param [NilClass, Hash] rest
      #   ассоциативный массив дополнительных параметров действия или `nil`,
      #   если дополнительные параметры отсутствуют
      # @raise [Sequel::ForeignKeyConstraintViolation]
      #   если запись заявки не найдена по предоставленному идентификатору
      # @raise [JSON::Schema::ValidationError]
      #   если в ассоциативном массиве параметров действия присутствует поле
      #   `type` или поле `created_at`
      def self.update(params, rest = nil)
        Update.new(params, rest).update
      end
    end
  end
end
