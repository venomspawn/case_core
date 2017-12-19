# encoding: utf-8

require 'securerandom'

require "#{$lib}/actions/base/action"

# Предварительное создание класса, чтобы не надо было указывать в дальнейшем
# базовый класс
CaseCore::Actions::Cases::Create = Class.new(CaseCore::Actions::Base::Action)

require "#{$lib}/helpers/log"
require "#{$lib}/helpers/safe_call"

require_relative 'create/params_schema'
require_relative 'mixins/logic'

module CaseCore
  module Actions
    module Cases
      # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
      #
      # Класс действий над записями заявок, предоставляющих метод `create`,
      # который создаёт новую запись заявки вместе с записями приложенных
      # документов
      #
      class Create
        include Helpers::Log
        include Helpers::SafeCall
        include Mixins::Logic
        include ParamsSchema

        # Создаёт новую запись заявки вместе с записями приложенных документов
        #
        def create
          c4s3 = Sequel::Model.db.transaction(savepoint: :only) do
            Models::Case.create(case_attrs).tap do |c4s3|
              create_attributes(c4s3)
              create_documents(c4s3)
            end
          end
          c4s3.tap(&method(:do_case_creation))
        end

        private

        # Создаёт и возвращает ассоциативный массив атрибутов записи заявки на
        # основе параметров действия
        #
        # @return [Hash]
        #   результирующий ассоциативный массив
        #
        def case_attrs
          params.slice(:id, :type).tap do |result|
            result[:id] ||= SecureRandom.uuid
            result[:created_at] = Time.now
          end
        end

        # Создаёт и возвращает ассоциативный массив атрибутов заявки,
        # подлежащих сохранению с помощью записей модели
        # {CaseCore::Models::CaseAttribute}
        #
        # @return [Hash]
        #   результирующий ассоциативный массив
        #
        def attributes_attrs
          params.except(:id, :type, :created_at, :documents)
        end

        # Возвращает список атрибутов записей документов
        #
        # @return [Array<Hash>]
        #   результирующий список
        #
        def documents_attrs
          params[:documents] || []
        end

        # Создаёт записи атрибутов заявки
        #
        # @param [CaseCore::Models::Case] c4s3
        #   запись заявки
        #
        def create_attributes(c4s3)
          attributes_attrs.each do |(name, value)|
            Models::CaseAttribute.create(name: name, value: value, case: c4s3)
          end
        end

        # Создаёт записи документов заявки
        #
        # @param [CaseCore::Models::Case] c4s3
        #   запись заявки
        #
        def create_documents(c4s3)
          documents_attrs.each do |document_attrs|
            Models::Document.create(document_attrs) do |document|
              document.id ||= SecureRandom.uuid
              document.case = c4s3
            end
          end
        end

        # Находит модуль бизнес-логики по значению поля `type` записи заявки
        # и вызывает у него метод `on_case_creation` с записью заявки в
        # качестве аргумента
        #
        # @param [CaseCore::Models::Case] c4s3
        #   запись заявки
        #
        def do_case_creation(c4s3)
          obj = logic(c4s3) || return
          _, e = safe_call(obj, :on_case_creation, c4s3)
          log_case_creation(e, c4s3, binding)
        end

        # Создаёт новую запись в журнале событий о том, как прошла обработка
        # бизнес-логикой создания заявки
        #
        # @param [NilClass, Exception] e
        #   объект с информацией об ошибке или `nil`, если ошибки не произошло
        #
        # @param [CaseCore::Models::Case] c4s3
        #   запись заявки
        #
        # @param [Binding] context
        #   контекст
        #
        def log_case_creation(e, c4s3, context)
          log_debug(context) { <<-LOG } if e.nil?
            Модулем бизнес-логики успешно обработано создание заявки с
            идентификатором `#{c4s3.id}` и типом `#{c4s3.type}`
          LOG
          log_error(context) { <<-LOG } unless e.nil?
            Во время обработки модулем бизнес-логики создания заявки с
            идентификатором `#{c4s3.id}` и типом `#{c4s3.type}` возникла
            ошибка `#{e.class}`: `#{e.message}`
          LOG
        end
      end
    end
  end
end
