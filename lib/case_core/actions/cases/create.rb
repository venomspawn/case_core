# frozen_string_literal: true

require 'securerandom'

require "#{$lib}/actions/base/action"
require "#{$lib}/actions/base/mixins/transactional"
require "#{$lib}/helpers/log"
require "#{$lib}/helpers/safe_call"

require_relative 'mixins/logic'

module CaseCore
  module Actions
    module Cases
      # Класс действий над записями заявок, предоставляющих метод `create`,
      # который создаёт новую запись заявки вместе с записями приложенных
      # документов
      class Create < Base::Action
        require_relative 'create/errors'
        require_relative 'create/params_schema'

        include Base::Mixins::Transactional
        include Cases::Mixins::Logic
        include Helpers::Log
        include Helpers::SafeCall

        # Создаёт новую запись заявки вместе с записями приложенных документов
        # @raise [RuntimeError]
        #   если не найдена бизнес-логика, обрабатывающая создание заявки
        # @raise [RuntimeError]
        #   если модуль бизнес-логики не предоставляет функцию
        #   `on_case_creation` для вызова с созданной заявкой в качестве
        #   аргумента
        # @raise [ArgumentError]
        #   если во время вызова функции `on_case_creation` модуля
        #   бизнес-логики создалось исключение класса `ArgumentError`
        def create
          transaction do
            Models::Case.create(case_attrs).tap do |c4s3|
              check_case_logic!(c4s3)
              create_attributes(c4s3)
              create_documents(c4s3)
              c4s3.tap(&method(:do_case_creation))
            end
          end
        end

        private

        # Создаёт и возвращает ассоциативный массив атрибутов записи заявки на
        # основе параметров действия
        # @return [Hash]
        #   результирующий ассоциативный массив
        def case_attrs
          params.slice(:id, :type).tap do |result|
            result[:id] ||= SecureRandom.uuid
            result[:created_at] = Time.now
          end
        end

        # Создаёт и возвращает ассоциативный массив атрибутов заявки,
        # подлежащих сохранению с помощью записей модели
        # {CaseCore::Models::CaseAttribute}
        # @return [Hash]
        #   результирующий ассоциативный массив
        def attributes_attrs
          params.except(:id, :type, :created_at, :documents)
        end

        # Возвращает список атрибутов записей документов
        # @return [Array<Hash>]
        #   результирующий список
        def documents_attrs
          params[:documents] || []
        end

        # Проверяет наличие модуля бизнес-логики для созданной заявки и наличие
        # функции `on_case_creation` у этого модуля
        # @param [CaseCore::Models::Case] c4s3
        #   созданная заявка
        # @raise [RuntimeError]
        #   если не найдена бизнес-логика, обрабатывающая создание заявки
        # @raise [RuntimeError]
        #   если модуль бизнес-логики не предоставляет функцию
        #   `on_case_creation` для вызова с созданной заявкой в качестве
        #   аргумента
        def check_case_logic!(c4s3)
          logic(c4s3).tap do |obj|
            raise Errors::Logic::NotFound.new(c4s3) if obj.nil?

            found = obj.respond_to?(:on_case_creation)
            raise Errors::OnCaseCreation::NotFound.new(c4s3) unless found
          end
        end

        # Список с названиями полей, импортируемых в таблицу атрибутов заявок
        IMPORT_FIELDS = %i[case_id name value].freeze

        # Создаёт записи атрибутов заявки
        # @param [CaseCore::Models::Case] c4s3
        #   запись заявки
        def create_attributes(c4s3)
          import_values = attributes_attrs.map do |(name, value)|
            [c4s3.id, name.to_s, value&.to_s]
          end
          Models::CaseAttribute.import(IMPORT_FIELDS, import_values)
        end

        # Создаёт записи документов заявки
        # @param [CaseCore::Models::Case] c4s3
        #   запись заявки
        def create_documents(c4s3)
          return if documents_attrs.empty?
          import_fields = documents_attrs.first.keys
          import_values = documents_attrs.map do |document_attrs|
            document_attrs.values_at(*import_fields).push(c4s3.id)
          end
          import_fields.push(:case_id)
          Models::Document.import(import_fields, import_values)
        end

        # Находит модуль бизнес-логики по значению поля `type` записи заявки
        # и вызывает у него метод `on_case_creation` с записью заявки в
        # качестве аргумента
        # @param [CaseCore::Models::Case] c4s3
        #   запись заявки
        # @raise [ArgumentError]
        #   если во время вызова функции `on_case_creation` модуля
        #   бизнес-логики создалось исключение класса `ArgumentError`
        def do_case_creation(c4s3)
          obj = logic(c4s3)
          _, err = safe_call(obj, :on_case_creation, c4s3)
          log_case_creation(err, c4s3, binding)
          raise err if err.is_a?(ArgumentError)
        end

        # Создаёт новую запись в журнале событий о том, как прошла обработка
        # бизнес-логикой создания заявки
        # @param [NilClass, Exception] err
        #   объект с информацией об ошибке или `nil`, если ошибки не произошло
        # @param [CaseCore::Models::Case] c4s3
        #   запись заявки
        # @param [Binding] context
        #   контекст
        def log_case_creation(err, c4s3, context)
          log_debug(context) { <<-LOG } if err.nil?
            Модулем бизнес-логики успешно обработано создание заявки с
            идентификатором `#{c4s3.id}` и типом `#{c4s3.type}`
          LOG
          log_error(context) { <<-LOG } unless err.nil?
            Во время обработки модулем бизнес-логики создания заявки с
            идентификатором `#{c4s3.id}` и типом `#{c4s3.type}` возникла
            ошибка `#{err.class}`: `#{err.message}`
          LOG
        end
      end
    end
  end
end
