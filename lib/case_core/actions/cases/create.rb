# encoding: utf-8

require 'securerandom'

require "#{$lib}/actions/base/action"

# Предварительное создание класса, чтобы не надо было указывать в дальнейшем
# базовый класс
CaseCore::Actions::Cases::Create = Class.new(CaseCore::Actions::Base::Action)

require_relative 'create/params_schema'

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
        include ParamsSchema

        # Создаёт новую запись заявки вместе с записями приложенных документов
        #
        def create
          Sequel::Model.db.transaction(savepoint: :only) do
            Models::Case.create(case_attrs).tap do |c4s3|
              create_attributes(c4s3)
              create_documents(c4s3)
            end
          end
        end

        private

        # Создаёт и возвращает ассоциативный массив атрибутов заявки, в котором
        # ключи приведены к типу Symbol, на основе параметров действия
        #
        # @return [Hash]
        #   результирующий ассоциативный массив
        #
        def attrs
          @attrs ||= params.deep_symbolize_keys
        end

        # Создаёт и возвращает ассоциативный массив атрибутов записи заявки на
        # основе параметров действия
        #
        # @return [Hash]
        #   результирующий ассоциативный массив
        #
        def case_attrs
          attrs.slice(:id, :type).tap do |result|
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
          attrs.except(:id, :type, :created_at, :documents)
        end

        # Возвращает список атрибутов записей документов
        #
        # @return [Array<Hash>]
        #   результирующий список
        #
        def documents_attrs
          attrs[:documents] || []
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
      end
    end
  end
end
