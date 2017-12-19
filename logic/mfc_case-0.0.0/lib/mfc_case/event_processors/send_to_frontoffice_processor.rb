# encoding: utf-8

module MFCCase
  module EventProcessors
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Класс обработчиков события `send_to_frontoffice!` заявки
    #
    class SendToFrontOfficeProcessor < Base::CaseEventProcessor
      # Выполняет следующие действия:
      #
      # *   выставляет статус заявки `issuance` в том и только в том случае,
      #     если статус заявки `processing`;
      # *   выставляет значение атрибута `responded_at` равным текущему
      #     времени;
      # *   выставляет значение атрибута `response_processor_person_id` равным
      #     значению дополнительного параметра `operator_id`;
      # *   выставляет значение атрибута `result_id` равным значению
      #     дополнительного параметра result_id
      #
      # @raise [RuntimeError]
      #   если статус заявки отличен от `processing`
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
        {
          status:                       'issuance',
          responded_at:                 now,
          response_processor_person_id: person_id,
          result_id:                    result_id
        }
      end

      # Возвращает значение параметра `result_id`
      #
      # @return [Object]
      #   значение параметра `result_id`
      #
      def result_id
        params[:result_id]
      end

      # Статус, из которого возможен переход в статус `issuance`
      #
      SUPPORTED_STATUS = 'processing'

      # Возвращает сообщение о том, что статус заявки невозможно выставить, так
      # из её статуса невозможен переход в статус `issuance`
      #
      STATUS_IS_NOT_SUPPORTED = proc { |status, c4s3| <<-MESSAGE.squish }
        Невозможно выставить новый статус, так как статус `#{status}`
        заявки с идентификатором записи `#{c4s3.id}` не равен статусу
        `#{SUPPORTED_STATUS}`
      MESSAGE

      # Проверяет, что статус заявки находится в списке {SUPPORTED_STATUSES}
      #
      # @raise [RuntimeError]
      #   если статус заявки не находится в списке {SUPPORTED_STATUSES}
      #
      def check_case_status!
        return if case_status == SUPPORTED_STATUS
        raise STATUS_IS_NOT_SUPPORTED[case_status, c4s3]
      end
    end
  end
end
