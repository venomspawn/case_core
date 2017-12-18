# encoding: utf-8

module MFCCase
  module EventProcessors
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Класс обработчиков события `add_to_pending_list!` заявки
    #
    class AddToPendingListProcessor
      # Выполняет следующие действия:
      #
      # *   выставляет статус заявки `pending` в том и только в том случае,
      #     если статус заявки `packaging` или `rejecting`;
      # *   выставляет значение атрибута `added_to_pending_at` равным текущему
      #     времени
      #
      # @raise [RuntimeError]
      #   если статус заявки отличен от `packaging` или `rejecting`
      #
      def process
        check_case_status!
        update_case_attributes(new_case_attributes)
      end

      private

      # Возвращает ассоциативный массив обновлённых атрибутов заявки
      #
      # @return [Hash]
      #   ассоциативный массив обновлённых атрибутов заявки
      #
      def new_case_attributes
        { status: 'pending', added_to_pending_at: Time.now }
      end

      # Список статусов, из которых возможен переход в статус `pending`
      #
      SUPPORTED_STATUSES = %w(packaging rejecting)

      # Возвращает сообщение о том, что статус заявки невозможно выставить, так
      # из её статуса невозможен переход в статус `pending`
      #
      STATUS_IS_NOT_SUPPORTED = proc { |status, c4s3| <<-MESSAGE.squish }
        Невозможно выставить статус `pending`, так как статус `#{status}`
        заявки с идентификатором записи `#{c4s3.id}` не равен ни одному из
        значений `#{SUPPORTED_STATUSES.join('`, `')}`
      MESSAGE

      # Проверяет, что статус заявки находится в списке {SUPPORTED_STATUSES}
      #
      # @raise [RuntimeError]
      #   если статус заявки не находится в списке {SUPPORTED_STATUSES}
      #
      def check_case_status!
        status = case_status
        return if SUPPORTED_STATUSES.include?(status)
        raise STATUS_IS_NOT_SUPPORTED[status, c4s3]
      end
    end
  end
end
