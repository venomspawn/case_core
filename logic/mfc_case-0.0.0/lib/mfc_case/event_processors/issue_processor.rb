# encoding: utf-8

module MFCCase
  module EventProcessors
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Класс обработчиков события `close!` заявки. Обработчик выполняет
    # следующие действия:
    #
    # *   выставляет статус заявки `closed` в том и только в том случае, если
    #     статус заявки `issuance`;
    # *   выставляет значение атрибута `issuer_person_id` равным значению
    #     дополнительного параметра `operator_id`;
    # *   выставляет значение атрибута `issued_at` равным текущему времени;
    # *   выставляет значение атрибута `closed_at` равным текущему времени.
    #
    class IssueProcessor < Base::CaseEventProcessor
      # Список статусов, из которых возможен переход в статус `closed`
      #
      ALLOWED_STATUSES = %w(issuance)

      # Список названий извлекаемых атрибутов заявки
      #
      ATTRS = [] # Не извлекаются никакие атрибуты, кроме атрибута `status`

      # Инициализирует объект класса
      #
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      #
      # @param [NilClass, Hash] params
      #   ассоциативный массив параметров обработчика события или `nil`, если
      #   обработчик не нуждается в параметрах
      #
      # @raise [ArgumentError]
      #   если аргумент `c4s3` не является объектом класса
      #   `CaseCore::Models::Case`
      #
      # @raise [ArgumentError]
      #   если аргумент `params` не является ни объектом класса `NilClass`,
      #   ни объектом класса `Hash`
      #
      # @raise [RuntimeError]
      #   если заявка обладает статусом, который недопустим для данного
      #   обработчика
      #
      def initialize(c4s3, params = nil)
        super(c4s3, ATTRS, ALLOWED_STATUSES, params)
      end

      private

      # Возвращает ассоциативный массив обновлённых атрибутов заявки
      #
      # @return [Hash]
      #   ассоциативный массив обновлённых атрибутов заявки
      #
      def new_case_attributes
        {
          status:           'closed',
          closed_at:        now,
          issuer_person_id: person_id,
          issued_at:        now
        }
      end
    end
  end
end
