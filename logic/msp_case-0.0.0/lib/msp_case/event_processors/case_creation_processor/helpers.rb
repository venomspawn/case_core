# encoding: utf-8

module MSPCase
  module EventProcessors
    class CaseCreationProcessor
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
      end
    end
  end
end
