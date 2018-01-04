# encoding: utf-8

module MSPCase
  module EventProcessors
    class IssueProcessor
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
          raise Errors::Case::InvalidClass
        end

        # Проверяет, что запись заявки обладает значением поля `type`, которое
        # равно `msp_case`
        #
        # @param [CaseCore::Models::Case] c4s3
        #   запись заявки
        #
        # @raise [RuntimeError]
        #   значение поля `type` записи заявки не равно `msp_case`
        #
        def check_case_type!(c4s3)
          return if c4s3.type == 'msp_case'
          raise Errors::Case::BadType.new(c4s3)
        end

        # Проверяет, что статус заявки `issuance`
        #
        # @param [CaseCore::Models::Case] c4s3
        #   запись заявки
        #
        # @param [Hash] case_attributes
        #   ассоциативный массив атрибутов заявки
        #
        # @raise [RuntimeError]
        #   если статус заявки отличен от `issuance`
        #
        def check_case_status!(c4s3, case_attributes)
          status = case_attributes[:status]
          return if status == 'issuance'
          raise Errors::Case::BadStatus.new(c4s3, status)
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
          raise Errors::Case::InvalidClass
        end
      end
    end
  end
end
