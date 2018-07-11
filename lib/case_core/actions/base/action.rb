# frozen_string_literal: true

require_relative 'mixins/validator'

module CaseCore
  # Пространство имён для действий над записями
  module Actions
    # Пространство имён для базовых классов действий над записями
    module Base
      # Базовый класс действия над записями. Реализует проверку параметров
      # действия согласно схеме, которая по умолчанию извлекается из константы
      # `PARAMS_SCHEMA` в пространстве имён класса, наследующего от данного.
      class Action
        extend Mixins::Validator

        # Инициализирует объект класса
        # @param [Object] params
        #   объект с информацией о параметрах действия, который может быть
        #   ассоциативным массивом, JSON-строкой или объектом, предоставляющим
        #   метод `#read`
        # @param [NilClass, Hash] rest
        #   ассоциативный массив дополнительных параметров действия или `nil`,
        #   если дополнительные параметры отсутствуют
        # @return [Hash{Symbol => Object}]
        #   результирующий ассоциативный массив параметров действия
        # @raise [Oj::ParseError, EncodingError]
        #   если предоставленный объект с информацией о параметрах действия
        #   является строкой, но не является корректной JSON-строкой
        # @raise [JSON::Schema::ValidationError]
        #   если результирующая структура не является ассоциативным массивом,
        #   соответствующим JSON-схеме
        def initialize(params, rest = nil)
          @params = process_params(params, rest)
        end

        private

        # Ассоциативный массив параметров действий
        # @return [Hash{Symbol => Object}]
        #   ассоциативный массив параметров действий
        attr_reader :params

        # Извлекает ассоциативный массив параметров действия из предоставленных
        # аргументов, проверяет его на соответствие JSON-схеме и возвращает его
        # @param [Object] params
        #   объект с информацией о параметрах действия, который может быть
        #   ассоциативным массивом, JSON-строкой или объектом, предоставляющим
        #   метод `#read`
        # @param [NilClass, Hash] rest
        #   ассоциативный массив дополнительных параметров действия или `nil`,
        #   если дополнительные параметры отсутствуют
        # @return [Hash{Symbol => Object}]
        #   результирующий ассоциативный массив параметров действия
        # @raise [Oj::ParseError, EncodingError]
        #   если предоставленный объект с информацией о параметрах действия
        #   является строкой, но не является корректной JSON-строкой
        # @raise [JSON::Schema::ValidationError]
        #   если результирующая структура не является ассоциативным массивом,
        #   соответствующим JSON-схеме
        def process_params(params, rest)
          return process_hash(params, rest) if params.is_a?(Hash)
          return process_json(params, rest) if params.is_a?(String)
          return process_read(params, rest) if params.respond_to?(:read)
          # Для генерации JSON::Schema::ValidationError
          validate!(params)
        end

        # Добавляет дополнительные параметры, если они даны, в предоставленный
        # ассоциативный массив, проверяет получившийся ассоциативный массив на
        # соответствие JSON-схеме и возвращает его
        # @param [Hash{Symbol => Object}] hash
        #   предоставленный ассоциативный массив
        # @param [NilClass, Hash] rest
        #   ассоциативный массив дополнительных параметров действия или `nil`,
        #   если дополнительные параметры отсутствуют
        # @return [Hash{Symbol => Object}]
        #   результирующий ассоциативный массив
        # @raise [JSON::Schema::ValidationError]
        #   если результирующий ассоциативный массив не соответствует
        #   JSON-схеме
        def process_hash(hash, rest)
          result = rest.nil? ? hash : hash.merge(rest)
          result.tap { validate!(stringify(result)) }
        end

        # Настройки восстановления структур данных из JSON-строк при помощи
        # `Oj` с ключами ассоциативных массивов типа `String`
        STRING_KEYS = { symbol_keys: false }.freeze

        # Выполняет следующие действия.
        #
        # 1.  Восстанавливает структуру из предоставленной JSON-строки.
        # 2.  Проверяет, что восстановленная структура является ассоциативным
        #     массивом.
        # 3.  Добавляет к восстановленному ассоциативному массиву
        #     дополнительные параметры, если такие предоставлены.
        # 4.  Проверяет полученный ассоциативный массив на соответствие
        #     JSON-схеме.
        # 5.  Возвращает проверенный ассоциативный массив.
        # @param [String] json
        #   предоставленная JSON-строка
        # @param [NilClass, Hash] rest
        #   ассоциативный массив дополнительных параметров действия или `nil`,
        #   если дополнительные параметры отсутствуют
        # @return [Hash{Symbol => Object}]
        #   восстановленный ассоциативный массив
        # @raise [Oj::ParseError, EncodingError]
        #   если во время восстановления произошла ошибка
        # @raise [JSON::Schema::ValidationError]
        #   если восстановленная структура не является ассоциативным массивом,
        #   соответствующим JSON-схеме
        def process_json(json, rest)
          # Восстановление с ключами типа String
          data = Oj.load(json, STRING_KEYS)
          # Для генерации JSON::Schema::ValidationError
          validate!(data) unless data.is_a?(Hash)
          data.update(stringify(rest)) unless rest.nil?
          validate!(data)
          # Восстановление с ключами типа Symbol
          data = Oj.load(json)
          rest.nil? ? data : data.update(rest)
        end

        # Считывает строку с помощью метода `#read` предоставленного объекта,
        # вызывая предварительно метод `#rewind`, если такой есть, и возвращает
        # результат метода {process_json} для считанной строки
        # @param [#read] stream
        #   предоставленный объект
        # @param [NilClass, Hash] rest
        #   ассоциативный массив дополнительных параметров действия или `nil`,
        #   если дополнительные параметры отсутствуют
        # @return [Hash{Symbol => Object}]
        #   восстановленный ассоциативный массив
        # @raise [Oj::ParseError, EncodingError]
        #   если во время восстановления произошла ошибка
        # @raise [JSON::Schema::ValidationError]
        #   если восстановленная структура не является ассоциативным массивом,
        #   соответствующим JSON-схеме
        def process_read(stream, rest)
          stream.rewind if stream.respond_to?(:rewind)
          process_json(stream.read.to_s, rest)
        end

        # Осуществляет проверку структуры на соответствие JSON-схеме.
        # Предполагает, что все ключи ассоциативных массивов и строки в
        # структуре приведены к типу `String` с помощью метода {stringify}.
        # @param [Object] data
        #   структура
        # @raise [JSON::Schema::ValidationError]
        #   если структура не соответствует JSON-схеме
        def validate!(data)
          self.class.validate!(data)
        end

        # Возвращает копию структуры, в которой все ключи ассоциативных
        # массивов и строки приведены к типу `String`
        # @param [Object] data
        #   структура
        # @return [Object] data
        #   приведённая копия структуры
        def stringify(data)
          self.class.stringify(data)
        end
      end
    end
  end
end
