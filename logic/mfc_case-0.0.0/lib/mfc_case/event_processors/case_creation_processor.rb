# encoding: utf-8

module MFCCase
  module EventProcessors
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Класс обработчиков события создания заявки
    #
    class CaseCreationProcessor < Base::CaseEventProcessor
      # Инициализирует объект класса
      #
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      #
      # @raise [ArgumentError]
      #   если аргумент `c4s3` не является объектом класса
      #   `CaseCore::Models::Case`
      #
      def initialize(c4s3)
        super
      end

      # Выставляет начальный статус заявки `packaging`
      #
      def process
        update_case_attributes(status: 'packaging')
      end
    end
  end
end
