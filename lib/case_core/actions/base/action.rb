# frozen_string_literal: true

require 'json-schema'

module CaseCore
  # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
  #
  # Пространство имён для действий над записями
  #
  module Actions
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Пространство имён для базовых классов действий над записями
    #
    module Base
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Базовый класс действия над записями. Реализует проверку параметров
      # действия согласно схеме, которая по умолчанию извлекается из константы
      # `PARAMS_SCHEMA` в пространстве имён класса, наследующего от данного.
      #
      class Action
        # Инициализирует объект класса
        #
        # @param [Object] params
        #   параметры действия
        #
        # @raise [NameError]
        #   если не найдена константа `PARAMS_SCHEMA` в пространстве имён
        #   класса, наследующего от данного
        #
        # @raise [JSON::Schema::ValidationError]
        #   если аргумент не является объектом требуемых типа и структуры
        #
        def initialize(params)
          JSON::Validator.validate!(params_schema, params, parse_data: false)
          @params = sanitize_params(params)
        end

        private

        # Параметры действия
        #
        # @return [Object]
        #   параметры действия
        #
        attr_reader :params

        # Возвращает параметры действия в исправленном виде
        #
        # @param [Object] params
        #   исходные параметры действия
        #
        # @return [Object]
        #   параметры действия в исправленном виде
        #
        def sanitize_params(params)
          case params
          when Hash
            params.deep_symbolize_keys
          when Array
            params.map(&method(:sanitize_params))
          else
            params
          end
        end

        # Возвращает схему, по которой проверяется объект параметров
        #
        # @return [Object]
        #   схема, по которой проверяет объект параметров
        #
        # @raise [NameError]
        #   если не найдена константа `PARAMS_SCHEMA` в пространстве имён
        #   класса, наследующего от данного
        #
        def params_schema
          self.class.const_get(:PARAMS_SCHEMA)
        end
      end
    end
  end
end
