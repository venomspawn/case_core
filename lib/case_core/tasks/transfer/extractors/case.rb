# frozen_string_literal: true

module CaseCore
  need 'helpers/log'

  module Tasks
    class Transfer
      module Extractors
        # Класс объектов, предоставляющих возможность извлечения информации о
        # заявке для импорта
        class Case
          include CaseCore::Helpers::Log

          # Возвращает ассоциативный массив атрибутов записи заявки, если
          # запись заявки возможно импортировать, или `nil` в противном
          # случае
          # @param [Hash] c4s3
          #   ассоциативный массив с информацией о заявке
          # @param [Enumerable] already_imported_ids
          #   коллекция уже импортированных идентификаторов записей заявок
          # @return [Hash]
          #   ассоциативный массив атрибутов записи заявки
          # @return [NilClass]
          #   если запись заявки невозможно импортировать
          def self.extract(c4s3, already_imported_ids)
            new(c4s3, already_imported_ids).extract
          end

          # Инициализирует объект класса
          # @param [Hash] c4s3
          #   ассоциативный массив с информацией о заявке
          # @param [Enumerable] already_imported_ids
          #   коллекция уже импортированных идентификаторов записей заявок
          # @return [Hash]
          #   ассоциативный массив атрибутов записи заявки
          def initialize(c4s3, already_imported_ids)
            @c4s3 = c4s3
            @already_imported_ids = already_imported_ids
          end

          # Возвращает ассоциативный массив атрибутов записи заявки, если
          # запись заявки возможно импортировать, или `nil` в противном
          # случае
          # @return [Hash]
          #   ассоциативный массив атрибутов записи заявки
          # @return [NilClass]
          #   если запись заявки невозможно импортировать
          def extract
            return if !supported_case_type? || already_imported?
            { id: id, type: type, created_at: created_at }
          end

          private

          # Ассоциативный массив с информацией о заявке
          # @return [Hash]
          #   ассоциативный массив с информацией о заявке
          attr_reader :c4s3

          # Коллекция уже импортированных идентификаторов записей заявок
          # @return [Enumerable]
          #   коллекция уже импортированных идентификаторов записей заявок
          attr_reader :already_imported_ids

          # Возвращает идентификатор записи заявки
          # @return [String]
          #   идентификатор записи заявки
          def id
            c4s3[:id]
          end

          # Возвращает название модели `case_manager` заявки
          # @return [String]
          #   название модели `case_manager` заявки
          def case_type
            c4s3[:case_type]
          end

          # Возвращает временную метку создания записи заявки в
          # `case_manager`
          # @return [Time]
          #   временная метка создания записи заявки в `case_manager`
          def created_at
            c4s3[:created_at]
          end

          # Ассоциативный массив, сопоставляющий названия классов моделей
          # заявок в `case_manager` и типы заявок в `case_core`
          TYPES = {
            'CaseManager::Models::CIKServiceCase'          => 'cik_case',
            'CaseManager::Models::SMEV2ServiceCase'        => 'esia_case',
            'CaseManager::Models::MFCFnsServiceCase'       => 'fns_case',
            'CaseManager::Models::FSSPServiceCase'         => 'fssp_case',
            'CaseManager::Models::NonAutomatedServiceCase' => 'mfc_case',
            'CaseManager::Models::MSPServiceCase'          => 'msp_case',
            'CaseManager::Models::MVDServiceCase'          => 'mvd_case'
          }.freeze

          # Возвращает тип заявки или `nil`, если классу модели заявки в
          # `case_manager` не соответствует никакой тип заявки в `case_core`
          # @return [String]
          #   тип заявки
          def type
            TYPES[case_type]
          end

          # Возвращает, поддерживается ли модель `case_manager` заявки
          # @return [Boolean]
          #   поддерживается ли модель `case_manager` заявки
          def supported_case_type?
            return true unless type.nil?
            log_unsupported_case_type(binding)
            false
          end

          # Создаёт запись в журнале событий о том, что тип заявки не
          # поддерживается
          # @param [Binding] context
          #   контекст
          def log_unsupported_case_type(context)
            log_warn(context) { <<-MESSAGE }
              Модель `#{case_type}` заявки с идентификатором записи `#{id}`
              не поддерживается
            MESSAGE
          end

          # Возвращает, импортирована ли уже заявка
          # @return [Boolean]
          #   импортирована ли уже заявка
          def already_imported?
            return false unless already_imported_ids.include?(id)
            log_already_imported(binding)
            true
          end

          # Создаёт запись в журнале событий о том, что заявка уже
          # импортирована
          # @param [Binding] context
          #   контекст
          def log_already_imported(context)
            log_info(context) { <<-MESSAGE }
              Запись заявки с идентификатором `#{id}` уже импортирована
            MESSAGE
          end
        end
      end
    end
  end
end
