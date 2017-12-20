# encoding: utf-8

module MFCCase
  module EventProcessors
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Класс обработчиков события создания заявки. Обработчик выставляет статус
    # заявки `packaging`.
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

      private

      # Возвращает ассоциативный массив обновлённых атрибутов заявки
      #
      # @return [Hash]
      #   ассоциативный массив обновлённых атрибутов заявки
      #
      def new_case_attributes
        { status: 'packaging' }
      end
    end
  end
end
