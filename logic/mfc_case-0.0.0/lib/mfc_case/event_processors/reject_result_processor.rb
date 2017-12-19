# encoding: utf-8

module MFCCase
  module EventProcessors
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Класс обработчиков события `reject_result!` заявки
    #
    class RejectResultProcessor < Base::CaseEventProcessor
      # Выполняет следующие действия:
      #
      # *   выставляет статус заявки `rejecting` в том и только в том случае,
      #     если одновременно выполнены следующие условия:
      #
      #     -   статус заявки `issuance`;
      #     -   значение атрибута `rejecting_expected_at` присутствует и
      #         представляет собой строку, в начале которой находится дата в
      #         формате `ГГГГ-ММ-ДД`;
      #     -  текущая дата больше значения, записанного в атрибуте
      #        `rejecting_expected_at`;
      #
      # *   выставляет значение атрибута `added_to_rejecting_at` равным
      #     текущему времени
      #
      # @raise [RuntimeError]
      #   если статус заявки отличен от `issuance`
      #
      # @raise [RuntimeError]
      #   если значение атрибута `rejecting_expected_at` отсутствует или не
      #   представляет собой строку в вышеописанном формате
      #
      def process
        check_conditions!
        update_case_attributes(new_case_attributes)
      end

      private

      # Возвращает ассоциативный массив обновлённых атрибутов заявки
      #
      # @return [Hash]
      #   ассоциативный массив обновлённых атрибутов заявки
      #
      def new_case_attributes
        { status: 'rejecting', added_to_rejecting_at: now }
      end

      # Возвращает значение атрибута `rejecting_expected_at` заявки
      #
      # @return [NilClass, String]
      #   значение атрибута `rejecting_expected_at` заявки
      #
      def rejecting_expected_at
        case_attributes[:rejecting_expected_at]
      end

      # Регулярное выражение для строки, в начале которой находится дата в
      # формате `ГГГГ-ММ-ДД`
      #
      DATE_STR_REGEXP = /^([0-9]{4})-([0-9]{2})-([0-9]{2}).*/

      # Проверяет, что значение атрибута `rejecting_expected_at` заявки
      # является строкой, в начале которой записана дата в формате
      # `ГГГГ-ММ-ДД`, и возвращает строку с этой датой
      #
      # @return [String]
      #   результирующая строка
      #
      # @raise [RuntimeError]
      #   если значение атрибута `rejecting_expected_at` отсутствует или не
      #   представляет собой строку, в начале которой находится дата в формате
      #   `ГГГГ-ММ-ДД`;
      #
      def rejecting_expected_at_date_str
        match_data = DATE_STR_REGEXP.match(rejecting_expected_at.to_s).to_a
        _, year, month, day = match_data
        Time.new(year, month, day).strftime('%F')
      rescue
        raise INVALID_DATE[rejecting_expected_at]
      end

      # Возвращает строку с текущей датой в формате `ГГГГ-ММ-ДД`
      #
      # @return [String]
      #   строка с текущей датой
      #
      def today_str
        now.strftime('%F')
      end

      # Возвращает, необходимо ли возвратить результат заявки в ведомство
      #
      # @return [Boolean]
      #   необходимо ли возвратить результат заявки в ведомство
      #
      def reject?
        rejecting_expected_at_date_str < today_str
      end

      # Статус, из которого возможен переход в статус `rejecting`
      #
      SUPPORTED_STATUS = 'issuance'

      # Возвращает сообщение о том, что статус заявки невозможно выставить, так
      # из её статуса невозможен переход в статус `rejecting`
      #
      STATUS_IS_NOT_SUPPORTED = proc { |status, c4s3| <<-MESSAGE.squish }
        Невозможно выставить новый статус, так как статус `#{status}`
        заявки с идентификатором записи `#{c4s3.id}` не равен статусу
        `#{SUPPORTED_STATUS}`
      MESSAGE

      # Возвращает сообщение о том, что статус заявки невозможно выставить, так
      # как ещё не наступила дата возврата результата заявки в ведомство
      #
      NOT_REJECTED = proc { |c4s3| <<-MESSAGE.squish }
        Невозможно выставить новый статус, так как дата возврата результат
        заявки с идентификатором `#{c4s3.id}` ещё не наступила
      MESSAGE

      # Проверяет условия выставления нового статуса
      #
      # @raise [RuntimeError]
      #   если статус заявки не равен 'issuance'
      #
      # @raise [RuntimeError]
      #   если значение атрибута `rejecting_expected_at` отсутствует или не
      #   представляет собой строку, в начале которой находится дата в формате
      #   `ГГГГ-ММ-ДД`;
      #
      # @raise [RuntimeError]
      #   если текущая дата не больше значения, записанного в атрибуте
      #   `rejecting_expected_at`;
      #
      def check_conditions!
        status = case_attributes[:status]
        not_supported = status != SUPPORTED_STATUS
        raise STATUS_IS_NOT_SUPPORTED[status, c4s3] if not_supported
        raise NOT_REJECTED[c4s3] unless reject?
      end
    end
  end
end
