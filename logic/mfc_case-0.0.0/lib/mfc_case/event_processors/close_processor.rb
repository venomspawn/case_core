# encoding: utf-8

module MFCCase
  module EventProcessors
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Класс обработчиков события `close!` заявки
    #
    class CloseProcessor
      # Выполняет следующие действия:
      #
      # *   выставляет статус заявки `closed` в том и только в том случае, если
      #     статус заявки `rejecting` или `issuance`;
      # *   если предыдущий статус заявки был `rejecting`, то выставляет
      #     значение атрибута `rejector_person_id` равным значению
      #     дополнительного параметра `operator_id`;
      # *   если предыдущий статус заявки был `rejecting`, то выставляет
      #     значение атрибута `rejected_at` равным текущему времени;
      # *   если предыдущий статус заявки был `issuance`, то выставляет
      #     значение атрибута `issuer_person_id` равным значению
      #     дополнительного параметра `operator_id`;
      # *   если предыдущий статус заявки был `issuance`, то выставляет
      #     значение атрибута `issued_at` равным текущему времени;
      # *   выставляет значение атрибута `closed_at` равным текущему времени
      #
      # @raise [RuntimeError]
      #   если статус заявки отличен от `processing`
      #
      def process
        check_case_status!
        update_case_attributes(new_case_attributes)
      end

      private

      # Возвращает статус заявки
      #
      # @return [String]
      #   статус заявки
      #
      def status
        @status ||= case_attributes[:status]
      end

      # Возвращает ассоциативный массив обновлённых атрибутов заявки
      #
      # @return [Hash]
      #   ассоциативный массив обновлённых атрибутов заявки
      #
      def new_case_attributes
        if status == rejecting
          {
            status:             'closed',
            closed_at:          now,
            rejector_person_id: person_id,
            rejected_at:        now
          }
        else
          {
            status:           'closed',
            closed_at:        now,
            issuer_person_id: person_id,
            issued_at:        now
          }
        end
      end

      # Список статусов, из которых возможен переход в статус `closed`
      #
      SUPPORTED_STATUSES = %w(rejecting issuance)

      # Возвращает сообщение о том, что статус заявки невозможно выставить, так
      # из её статуса невозможен переход в статус `closed`
      #
      STATUS_IS_NOT_SUPPORTED = proc { |status, c4s3| <<-MESSAGE.squish }
        Невозможно выставить новый статус, так как статус `#{status}`
        заявки с идентификатором записи `#{c4s3.id}` не равен ни одному из
        значений `#{SUPPORTED_STATUSES.join('`, `')}`
      MESSAGE

      # Проверяет, что статус заявки находится в списке {SUPPORTED_STATUSES}
      #
      # @raise [RuntimeError]
      #   если статус заявки не находится в списке {SUPPORTED_STATUSES}
      #
      def check_case_status!
        return if SUPPORTED_STATUSES.include?(status)
        raise STATUS_IS_NOT_SUPPORTED[status, c4s3]
      end
    end
  end
end
