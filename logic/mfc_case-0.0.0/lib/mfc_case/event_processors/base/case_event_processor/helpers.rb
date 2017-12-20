# encoding: utf-8

module MFCCase
  module EventProcessors
    module Base
      class CaseEventProcessor
        # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
        #
        # Вспомогательный модуль, предназначенный для включения в содержащий
        # класс
        #
        module Helpers
          # Проверяет, что аргумент является объектом класса
          # `CaseCore::Models::Case`
          #
          # @param [Object] c4s3
          #   аргумент
          #
          # @raise [ArgumentError]
          #   если аргумент не является объектом класса
          #   `CaseCore::Models::Case`
          #
          def check_case!(c4s3)
            return if c4s3.is_a?(CaseCore::Models::Case)
            raise Errors::Case::BadType
          end

          # Проверяет, что аргумент является объектом класса `NilClass` или
          # класса `Array`
          #
          # @params [Hash] attrs
          #   аргумент
          #
          # @raise [ArgumentError]
          #   если аргумент не является ни объектом класса `NilClass`, ни
          #   объектом класса `Array`
          #
          def check_attrs!(attrs)
            return if attrs.nil? || attrs.is_a?(Array)
            raise Errors::Attrs::BadType
          end

          # Проверяет, что аргумент является объектом класса `NilClass` или
          # класса `Array`
          #
          # @params [Hash] allowed_statuses
          #   аргумент
          #
          # @raise [ArgumentError]
          #   если аргумент не является ни объектом класса `NilClass`, ни
          #   объектом класса `Array`
          #
          def check_allowed_statuses!(allowed_statuses)
            return if allowed_statuses.nil? || allowed_statuses.is_a?(Array)
            raise Errors::AllowedStatuses::BadType
          end

          # Проверяет, что аргумент является объектом класса `NilClass` или
          # класса `Hash`
          #
          # @params [Hash] params
          #   аргумент
          #
          # @raise [ArgumentError]
          #   если аргумент не является ни объектом класса `NilClass`, ни
          #   объектом класса `Hash`
          #
          def check_params!(params)
            return if params.nil? || params.is_a?(Hash)
            raise Errors::Params::BadType
          end

          # Поддерживаемые статусы заявок
          #
          STATUSES = %w(packaging pending processing issuance rejecting closed)

          # Возвращает сообщение о том, что значение атрибута `status` записи
          # заявки не поддерживается
          #
          BAD_STATUS = proc { |status, c4s3| <<-MESSAGE.squish }
            Значение `#{status}` атрибута `status` записи заявки с
            идентификатором `#{c4s3.id} не поддерживается
          MESSAGE

          # Проверяет, что значение атрибута `status` заявки допустимо
          #
          # @param [CaseCore::Models::Case] c4s3
          #   запись заявки
          #
          # @param [Hash] case_attributes
          #   ассоциативный массив атрибутов заявки
          #
          # @param [NilClass, Array] allowed_statuses
          #   список статусов заявки, которые допустимы для данного
          #   обработчика, или `nil`, если допустим любой статус, а также его
          #
          # @raise [RuntimeError]
          #   если значение атрибута `status` не является допустимым
          #
          def check_case_status!(c4s3, case_attributes, allowed_statuses)
            return if allowed_statuses.nil?
            status = case_attributes[:status]
            allowed_statuses.map!(&:to_s)
            return if allowed_statuses.include?(status)
            raise Errors::Case::BadStatus.new(c4s3, status, allowed_stauses)
          end
        end
      end
    end
  end
end
