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
          raise Errors::Case::BadType unless c4s3.is_a?(CaseCore::Models::Case)
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
      end
    end
  end
end
