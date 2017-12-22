# encoding: utf-8

Dir["#{__dir__}/issue_processor/*.rb"].each(&method(:load))

module MSPCase
  module EventProcessors
    # @author Александр Ильчуков <a.s.ilchukov@cit.rkomi.ru>
    #
    # Класс обработчиков события `issue` заявки. Обработчик выполняет следующие
    # действия:
    #
    # *   выставляет статус заявки `closed` в том и только в том случае, если
    #     статус заявки `issuance`;
    # *   выставляет значение атрибута `closed_at` равным текущим дате и
    #     времени.
    #
    class IssueProcessor
      include Helpers

      # Инициализирует объект класса
      #
      # @param [CaseCore::Models::Case] c4s3
      #   запись заявки
      #
      # @param [NilClass, Hash] params
      #   ассоциативный массив параметров или `nil`
      #
      # @raise [ArgumentError]
      #   если аргумент `c4s3` не является объектом класса
      #   `CaseCore::Models::Case`
      #
      # @raise [ArgumentError]
      #   если аргумент `params` не является объектом класса `NilClass` или
      #   класса `Hash`
      #
      # @raise [RuntimeError]
      #   если статус заявки отличен от `issuance`
      #
      def initialize(c4s3, params)
        check_case!(c4s3)
        check_params!(params)
        @c4s3 = c4s3
        @params = params || {}
      end

      # Выполняет обработку
      #
      def process
        check_conditions!
        update_case_attributes
      end

      private

      # Запись заявки
      #
      # @return [CaseCore::Models::Case]
      #   запись заявки
      #
      attr_reader :c4s3

      # Ассоциативный массив параметров обработчика события
      #
      # @return [Hash]
      #   ассоциативный массив параметров обработчика события
      #
      attr_reader :params

      # Возвращает ассоциативный массив атрибутов заявки
      #
      # @return [Hash]
      #   ассоциативный массив атрибутов заявки
      #
      def case_attributes
        @case_attributes ||= extract_case_attributes
      end

      # Названия требуемых атрибутов заявки
      #
      CASE_ATTRS = %w(status)

      # Извлекает требуемые атрибуты заявки из соответствующих записей и
      # возвращает ассоциативный массив атрибутов заявки
      #
      # @return [Hash{Symbol => Object}]
      #   результирующий ассоциативный массив
      #
      def extract_case_attributes
        CaseCore::Actions::Cases
          .show_attributes(id: c4s3.id, names: CASE_ATTRS)
      end

      # Обновляет атрибуты заявки
      #
      def update_case_attributes
        CaseCore::Actions::Cases.update(id: c4s3.id, **new_case_attributes)
      end

      # Возвращает ассоциативный массив новых атрибутов заявки
      #
      # @return [Hash]
      #   ассоциативный массив новых атрибутов заявки
      #
      def new_case_attributes
        { status: 'closed', closed_at: Time.now }
      end

      # Возвращает статус заявки
      #
      # @return [NilClass, String]
      #   статус заявки
      #
      def case_status
        case_attributes[:status]
      end

      # Проверяет, что статус заявки `issuance`
      #
      # @raise [RuntimeError]
      #   если статус заявки отличен от `issuance`
      #
      def check_conditions!
        return if case_status == 'issuance'
        raise Errors::Case::BadStatus.new(c4s3, case_status)
      end
    end
  end
end
