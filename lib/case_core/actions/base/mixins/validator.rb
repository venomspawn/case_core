# frozen_string_literal: true

require 'json-schema'

module CaseCore
  module Actions
    module Base
      module Mixins
        # Модуль, предназначенный для расширения классами и предоставляющий
        # методы для проверки структур на соответствие JSON-схеме
        module Validator
          # Осуществляет проверку структуры на соответствие JSON-схеме.
          # Предполагает, что все ключи ассоциативных массивов и строки в
          # структуре приведены к типу `String` с помощью метода {stringify}.
          # @param [Object] data
          #   структура
          # @raise [JSON::Schema::ValidationError]
          #   если структура не соответствует JSON-схеме
          def validate!(data)
            validator.instance_exec do
              @data = data
              validate
            end
          end

          # Возвращает копию структуры, в которой все ключи ассоциативных
          # массивов и строки приведены к типу `String`
          # @param [Object] data
          #   структура
          # @return [Object] data
          #   приведённая копия структуры
          def stringify(data)
            JSON::Schema.stringify(data)
          end

          private

          # Возвращает схему, на соответствие которой происходит проверка. Для
          # этого извлекает константу `PARAMS_SCHEMA` из класса.
          # @return [Hash]
          #   результирующая схема
          # @raise [NameError]
          #   если константа `PARAMS_SCHEMA` отсутствует в классе
          def schema
            self::PARAMS_SCHEMA
          end

          # Настройки объекта, осуществляющего проверку на соответствие
          # JSON-схеме
          VALIDATOR_OPTIONS = { parse_data: false }.freeze

          # Возвращает объект, осуществляющий проверку на соответствие
          # JSON-схеме
          # @return [JSON::Validator]
          #   результирующий объект
          def validator
            @validator ||= JSON::Validator.new(schema, nil, VALIDATOR_OPTIONS)
          end
        end
      end
    end
  end
end
