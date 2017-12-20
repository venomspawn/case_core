# encoding: utf-8

module MFCCase
  module EventProcessors
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Класс обработчиков события `reject_result!` заявки. Обработчик выполняет
    # следующие действия:
    #
    # *   выставляет статус заявки `rejecting` в том и только в том случае,
    #     если одновременно выполнены следующие условия:
    #
    #     -   статус заявки `issuance`;
    #     -   значение атрибута `rejecting_expected_at` присутствует и
    #         представляет собой строку, в начале которой находится дата в
    #         формате `ГГГГ-ММ-ДД`;
    #     -   текущая дата больше значения, записанного в атрибуте
    #         `rejecting_expected_at`;
    #
    # *   выставляет значение атрибута `added_to_rejecting_at` равным
    #     текущему времени.
    #
    class RejectResultProcessor < Base::CaseEventProcessor
      # Список статусов, из которых возможен переход в статус `rejecting`
      #
      ALLOWED_STATUSES = %w(issuance)

      # Список названий извлекаемых атрибутов заявки
      #
      ATTRS = %w(rejecting_expected_at) # + атрибут `status`

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

      # Проверяет условия и обновляет атрибуты заявки
      #
      # @raise [RuntimeError]
      #   если значение атрибута `rejecting_expected_at` отсутствует или не
      #   представляет собой строку, в начале которой находится дата в формате
      #   `ГГГГ-ММ-ДД`;
      #
      def process
        check_conditions!
        super
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
        raise Errors::Date::InvalidFormat.new(rejecting_expected_at)
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
      def expired?
        rejecting_expected_at_date_str < today_str
      end

      # Проверяет условия выставления нового статуса
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
        raise Errors::Date::NotExpired.new(c4s3) unless expired?
      end
    end
  end
end
