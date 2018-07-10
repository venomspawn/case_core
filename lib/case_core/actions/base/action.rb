# frozen_string_literal: true

require 'json-schema'

module CaseCore
  # Пространство имён для действий над записями
  module Actions
    # Пространство имён для базовых классов действий над записями
    module Base
      # Базовый класс действия над записями. Реализует проверку параметров
      # действия согласно схеме, которая по умолчанию извлекается из константы
      # `PARAMS_SCHEMA` в пространстве имён класса, наследующего от данного.
      class Action
        # Инициализирует объект класса
        # @param [Object] params
        #   параметры действия
        # @param [NilClass, Hash] rest
        #   ассоциативный массив дополнительных параметров действия или `nil`,
        #   если дополнительные параметры отсутствуют
        # @raise [NameError]
        #   если не найдена константа `PARAMS_SCHEMA` в пространстве имён
        #   класса, наследующего от данного
        # @raise [JSON::Schema::ValidationError]
        #   если аргумент не является объектом требуемых типа и структуры
        def initialize(params, rest = nil)
          @params = process_params(params, rest)
        end

        private

        # Параметры действия
        # @return [Object]
        #   параметры действия
        attr_reader :params

        # @param [Object] params
        #   параметры действия
        # @param [NilClass, Hash] rest
        #   дополнительные параметры действия
        # @return [Object]
        #   проверенные объединённые параметры действия
        # @raise [JSON::Schema::ValidationError]
        #   если аргумент не является объектом требуемых типа и структуры
        def process_params(params, rest)
          params = load_from_json(params)   if params.is_a?(String)
          params = load_from_stream(params) if params.respond_to?(:read)
          params.update(rest) unless rest.nil?
          JSON::Validator.validate!(params_schema, params, parse_data: false)
          params
        end

        # Возвращает структуру, восстановленную из предоставленной JSON-строки
        # @param [String] json
        #   предоставленная JSON-строка
        # @return [Object]
        #   восстановленная структура
        # @raise [Oj::ParseError]
        #   если во время восстановления произошла ошибка
        def load_from_json(json)
          Oj.load(json)
        end

        # Вызывает метод `read` у предоставленного объекта и возвращает
        # структуру, восстановленную из значения, которое вернул метод. Если
        # объект дополнительно предоставляет метод `rewind`, то вызывает его
        # перед вызовом `read`.
        # @param [#read] stream
        #   предоставленный объект
        # @return [Object]
        #   восстановленная структура
        # @raise [Oj::ParseError]
        #   если во время восстановления произошла ошибка
        def load_from_stream(stream)
          stream.rewind if stream.respond_to?(:rewind)
          load_from_json(stream.read.to_s)
        end

        # Возвращает схему, по которой проверяется объект параметров
        # @return [Object]
        #   схема, по которой проверяет объект параметров
        # @raise [NameError]
        #   если не найдена константа `PARAMS_SCHEMA` в пространстве имён
        #   класса, наследующего от данного
        def params_schema
          self.class.const_get(:PARAMS_SCHEMA)
        end
      end
    end
  end
end
