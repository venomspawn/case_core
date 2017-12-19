# encoding: utf-8

module MFCCase
  module EventProcessors
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Класс обработчиков события `send_to_institution!` заявки
    #
    class SendToInstitutionProcessor < Base::CaseEventProcessor
      # Выполняет следующие действия:
      #
      # *   выставляет статус заявки `processing` в том и только в том случае,
      #     если одновременно выполнены следующие условия:
      #
      #     -   статус заявки `packaging` или `pending`;
      #     -   значение атрибута `issue_location_type` не равно `institution`;
      #     -   значение атрибута `added_to_rejecting_at` отсутствует или
      #         пусто;
      #
      # *   выставляет статус заявки `closed` в том и только в том случае, если
      #     одновременно выполнены следующие условия:
      #
      #     -   статус заявки `packaging` или `pending`;
      #     -   значение атрибута `issue_location_type` равно `institution`,
      #         или значение атрибута `added_to_rejecting_at` присутствует;
      #
      # *   выставляет значение атрибута `docs_sent_at` равным текущему
      #     времени;
      # *   выставляет значение атрибута `processor_person_id` равным значению
      #     дополнительного параметра `operator_id`.
      #
      # @raise [RuntimeError]
      #   если статус заявки отличен от `packaging` или `pending`
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
          status:              new_status,
          docs_sent_at:        now,
          processor_person_id: person_id
        }
      end

      # Возвращает новый статус заявки
      #
      # @return ['closed']
      #   если значение атрибута `issue_location_type` заявки равно строке
      #   `institution` или значение атрибута `added_to_rejecting_at`
      #   присутствует
      #
      # @return ['processing']
      #   если значение атрибута `issue_location_type` заявки не равно строке
      #   `institution` и значение атрибута `added_to_rejecting_at` пусто
      #
      def new_status
        if issue_location_institution? || added_to_rejecting_at.present?
          'closed'
        else
          'processing'
        end
      end

      # Возвращает значение атрибута `issue_location_type` заявки
      #
      # @return [NilClass, String]
      #   значение атрибута `issue_location_type` заявки
      #
      def issue_location_type
        case_attributes[:issue_location_type]
      end

      # Возвращает значение атрибута `added_to_rejecting_at` заявки
      #
      # @return [NilClass, String]
      #   значение атрибута `added_to_rejecting_at` заявки
      #
      def added_to_rejecting_at
        case_attributes[:added_to_rejecting_at]
      end

      # Возвращает, равно ли значение атрибута `issue_location_type` заявки
      # строке `institution`
      #
      # @return [Boolean]
      #   равно ли значение атрибута `issue_location_type` заявки строке
      #   `institution`
      #
      def issue_location_institution?
        issue_location_type == 'institution'
      end

      # Список статусов, из которых возможен переход в статус `pending`
      #
      SUPPORTED_STATUSES = %w(packaging pending)

      # Возвращает сообщение о том, что статус заявки невозможно выставить, так
      # из её статуса невозможен переход в статус `pending`
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
        status = case_attributes[:status]
        return if SUPPORTED_STATUSES.include?(status)
        raise STATUS_IS_NOT_SUPPORTED[status, c4s3]
      end
    end
  end
end
