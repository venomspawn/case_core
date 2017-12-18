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
          # Сообщение о том, что аргумент `c4s3` не является объектом класса
          # `CaseCore::Models::Case`
          #
          BAD_CASE_TYPE = <<-MESSAGE.squish
            Аргумент `c4s3` не является объектом класса
            `CaseCore::Models::Case`
          MESSAGE

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
            raise ArgumentError, BAD_CASE_TYPE
          end

          # Сообщение о том, что аргумент `params` не является объектом класса
          # `NilClass` или класса `Hash`
          #
          BAD_PARAMS_TYPE = <<-MESSAGE.squish
            Аргумент `params` не является объектом класса `NilClass` или
            класса `Hash`
          MESSAGE

          # Проверяет, что аргумент является объектом класса `NilClass` или
          # класса `Hash`
          #
          # @params [Hash] params
          #   аргумент
          #
          # @raise [ArgumentError]
          #   если аргумент не является объектом класса `NilClass` или класса
          #   `Hash`
          #
          def check_params!(params)
            return if params.nil? || params.is_a?(Hash)
            raise ArgumentError, BAD_PARAMS_TYPE
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

          # Проверяет, что значение аргумента находится среди значений
          # элементов списка {STATUSES}
          #
          # @param [Object] status
          #   аргумент
          #
          # @param [CaseCore::Models::Case] c4s3
          #   запись заявки
          #
          # @raise [RuntimeError]
          #   если значение аргумента не находится среди значений элементов
          #   списка {STATUSES}
          #
          def check_status!(status, c4s3)
            raise BAD_STATUS[status, c4s3] unless STATUSES.include?(status)
          end
        end
      end
    end
  end
end
